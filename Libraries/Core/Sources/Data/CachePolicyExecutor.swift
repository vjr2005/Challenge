import Foundation

/// Executes data fetch operations using the cache strategy defined by a `CachePolicy`.
///
/// Supports single-level (memory only) and two-level (memory + disk) caching.
/// When persistence closures are provided, the executor coordinates L1 (memory)
/// and L2 (disk) automatically: reads try L1 → L2 (promoting to L1) → remote,
/// writes save to both levels.
///
/// Repositories inject this executor and delegate cache strategy logic to it.
public struct CachePolicyExecutor {
	public init() {}

	/// Executes a data fetch using the given cache policy.
	///
	/// - Parameters:
	///   - policy: The cache strategy to apply.
	///   - fetchFromRemote: Closure that fetches data from the remote source (untyped throws).
	///   - getFromVolatile: Closure that retrieves data from L1 (memory) cache, returning `nil` on miss.
	///   - getFromPersistence: Closure that retrieves data from L2 (disk) cache, returning `nil` on miss.
	///   - saveToVolatile: Closure that persists data to L1 (memory) cache.
	///   - saveToPersistence: Closure that persists data to L2 (disk) cache.
	///   - mapper: Closure that transforms the raw DTO into a domain model.
	///   - errorMapper: Closure that maps transport errors to domain errors.
	/// - Returns: The domain model produced by the mapper.
	public func execute<DTO, Domain, Failure: Error>(
		policy: CachePolicy,
		fetchFromRemote: () async throws -> DTO,
		getFromVolatile: () async -> DTO?,
		getFromPersistence: (() async -> DTO?)? = nil,
		saveToVolatile: (DTO) async -> Void,
		saveToPersistence: ((DTO) async -> Void)? = nil,
		mapper: (DTO) -> Domain,
		errorMapper: (any Error) -> Failure
	) async throws(Failure) -> Domain {
		switch policy {
		case .localFirst:
			try await executeLocalFirst(
				fetchFromRemote: fetchFromRemote,
				getFromVolatile: getFromVolatile,
				getFromPersistence: getFromPersistence,
				saveToVolatile: saveToVolatile,
				saveToPersistence: saveToPersistence,
				mapper: mapper,
				errorMapper: errorMapper
			)
		case .remoteFirst:
			try await executeRemoteFirst(
				fetchFromRemote: fetchFromRemote,
				getFromVolatile: getFromVolatile,
				getFromPersistence: getFromPersistence,
				saveToVolatile: saveToVolatile,
				saveToPersistence: saveToPersistence,
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
		getFromVolatile: () async -> DTO?,
		getFromPersistence: (() async -> DTO?)? = nil,
		saveToVolatile: (DTO) async -> Void,
		saveToPersistence: ((DTO) async -> Void)? = nil,
		mapper: (DTO) -> Domain,
		errorMapper: (any Error) -> Failure
	) async throws(Failure) -> Domain {
		if let cached = await getFromVolatile() {
			return mapper(cached)
		}
		if let persisted = await getFromPersistence?() {
			await saveToVolatile(persisted)
			return mapper(persisted)
		}
		do {
			let dto = try await fetchFromRemote()
			await saveToVolatile(dto)
			await saveToPersistence?(dto)
			return mapper(dto)
		} catch {
			throw errorMapper(error)
		}
	}

	func executeRemoteFirst<DTO, Domain, Failure: Error>(
		fetchFromRemote: () async throws -> DTO,
		getFromVolatile: () async -> DTO?,
		getFromPersistence: (() async -> DTO?)? = nil,
		saveToVolatile: (DTO) async -> Void,
		saveToPersistence: ((DTO) async -> Void)? = nil,
		mapper: (DTO) -> Domain,
		errorMapper: (any Error) -> Failure
	) async throws(Failure) -> Domain {
		do {
			let dto = try await fetchFromRemote()
			await saveToVolatile(dto)
			await saveToPersistence?(dto)
			return mapper(dto)
		} catch {
			if let cached = await getFromVolatile() {
				return mapper(cached)
			}
			if let persisted = await getFromPersistence?() {
				await saveToVolatile(persisted)
				return mapper(persisted)
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
