import Foundation

/// Executes data fetch operations using the cache strategy defined by a `CachePolicy`.
///
/// Follows the same pattern as `MapperContract` implementations: a stateless struct
/// that encapsulates a single operation. Repositories inject this executor and delegate
/// cache strategy logic to it.
public struct CachePolicyExecutor {
	public init() {}

	/// Executes a data fetch using the given cache policy.
	///
	/// - Parameters:
	///   - policy: The cache strategy to apply.
	///   - fetchFromRemote: Closure that fetches data from the remote source (untyped throws).
	///   - getFromCache: Closure that retrieves cached data, returning `nil` on cache miss.
	///   - saveToCache: Closure that persists data to the local cache.
	///   - mapper: Closure that transforms the raw DTO into a domain model.
	///   - errorMapper: Closure that maps transport errors to domain errors.
	/// - Returns: The domain model produced by the mapper.
	public func execute<DTO, Domain, Failure: Error>(
		policy: CachePolicy,
		fetchFromRemote: () async throws -> DTO,
		getFromCache: () async -> DTO?,
		saveToCache: (DTO) async -> Void,
		mapper: (DTO) -> Domain,
		errorMapper: (any Error) -> Failure
	) async throws(Failure) -> Domain {
		switch policy {
		case .localFirst:
			try await executeLocalFirst(
				fetchFromRemote: fetchFromRemote,
				getFromCache: getFromCache,
				saveToCache: saveToCache,
				mapper: mapper,
				errorMapper: errorMapper
			)
		case .remoteFirst:
			try await executeRemoteFirst(
				fetchFromRemote: fetchFromRemote,
				getFromCache: getFromCache,
				saveToCache: saveToCache,
				mapper: mapper,
				errorMapper: errorMapper
			)
		case .noCache:
			try await executeNoCache(
				fetchFromRemote: fetchFromRemote,
				mapper: mapper,
				errorMapper: errorMapper
			)
		}
	}
}

// MARK: - Cache Strategies

private extension CachePolicyExecutor {
	func executeLocalFirst<DTO, Domain, Failure: Error>(
		fetchFromRemote: () async throws -> DTO,
		getFromCache: () async -> DTO?,
		saveToCache: (DTO) async -> Void,
		mapper: (DTO) -> Domain,
		errorMapper: (any Error) -> Failure
	) async throws(Failure) -> Domain {
		if let cached = await getFromCache() {
			return mapper(cached)
		}
		do {
			let dto = try await fetchFromRemote()
			await saveToCache(dto)
			return mapper(dto)
		} catch {
			throw errorMapper(error)
		}
	}

	func executeRemoteFirst<DTO, Domain, Failure: Error>(
		fetchFromRemote: () async throws -> DTO,
		getFromCache: () async -> DTO?,
		saveToCache: (DTO) async -> Void,
		mapper: (DTO) -> Domain,
		errorMapper: (any Error) -> Failure
	) async throws(Failure) -> Domain {
		do {
			let dto = try await fetchFromRemote()
			await saveToCache(dto)
			return mapper(dto)
		} catch {
			if let cached = await getFromCache() {
				return mapper(cached)
			}
			throw errorMapper(error)
		}
	}

	func executeNoCache<DTO, Domain, Failure: Error>(
		fetchFromRemote: () async throws -> DTO,
		mapper: (DTO) -> Domain,
		errorMapper: (any Error) -> Failure
	) async throws(Failure) -> Domain {
		do {
			let dto = try await fetchFromRemote()
			return mapper(dto)
		} catch {
			throw errorMapper(error)
		}
	}
}
