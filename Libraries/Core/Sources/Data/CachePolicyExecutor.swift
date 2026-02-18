import Foundation

/// Executes data fetch operations using the cache strategy defined by a `CachePolicy`.
///
/// Follows the same pattern as `MapperContract` implementations: a stateless struct
/// that encapsulates a single operation. Repositories inject this executor and delegate
/// cache strategy logic to it.
nonisolated public struct CachePolicyExecutor: Sendable {
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
		fetchFromRemote: sending () async throws -> DTO,
		getFromCache: sending () async -> DTO?,
		saveToCache: sending (DTO) async -> Void,
		mapper: sending (DTO) -> Domain,
		errorMapper: sending (any Error) -> Failure
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

nonisolated private extension CachePolicyExecutor {
	func executeLocalFirst<DTO, Domain, Failure: Error>(
		fetchFromRemote: sending () async throws -> DTO,
		getFromCache: sending () async -> DTO?,
		saveToCache: sending (DTO) async -> Void,
		mapper: sending (DTO) -> Domain,
		errorMapper: sending (any Error) -> Failure
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
		fetchFromRemote: sending () async throws -> DTO,
		getFromCache: sending () async -> DTO?,
		saveToCache: sending (DTO) async -> Void,
		mapper: sending (DTO) -> Domain,
		errorMapper: sending (any Error) -> Failure
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
		fetchFromRemote: sending () async throws -> DTO,
		mapper: sending (DTO) -> Domain,
		errorMapper: sending (any Error) -> Failure
	) async throws(Failure) -> Domain {
		do {
			let dto = try await fetchFromRemote()
			return mapper(dto)
		} catch {
			throw errorMapper(error)
		}
	}
}
