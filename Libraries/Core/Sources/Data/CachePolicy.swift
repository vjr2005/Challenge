import Foundation

/// Policy for controlling cache behavior when fetching data.
nonisolated public enum CachePolicy {
	/// Cache first, remote if not found. Default behavior.
	case localFirst

	/// Remote first, cache as fallback on error.
	case remoteFirst

	/// Only remote, no cache interaction.
	case noCache

	/// Fetches data applying this cache strategy.
	///
	/// - Parameters:
	///   - fromRemote: Fetches from the network.
	///   - fromCache: Returns the cached value, or `nil` on a miss.
	///   - saveToCache: Persists a freshly fetched value to the cache.
	/// - Throws: The original transport error, untyped.
	public func fetch<Value>(
		fromRemote: sending () async throws -> Value,
		fromCache: sending () async -> Value?,
		saveToCache: sending (Value) async -> Void
	) async throws -> Value {
		switch self {
		case .localFirst:
			try await Self.fetchLocalFirst(fromRemote: fromRemote, fromCache: fromCache, saveToCache: saveToCache)
		case .remoteFirst:
			try await Self.fetchRemoteFirst(fromRemote: fromRemote, fromCache: fromCache, saveToCache: saveToCache)
		case .noCache:
			try await fromRemote()
		}
	}
}

// MARK: - Cache Strategies

nonisolated private extension CachePolicy {
	static func fetchLocalFirst<Value>(
		fromRemote: sending () async throws -> Value,
		fromCache: sending () async -> Value?,
		saveToCache: sending (Value) async -> Void
	) async throws -> Value {
		if let cached = await fromCache() {
			return cached
		}
		let value = try await fromRemote()
		await saveToCache(value)
		return value
	}

	static func fetchRemoteFirst<Value>(
		fromRemote: sending () async throws -> Value,
		fromCache: sending () async -> Value?,
		saveToCache: sending (Value) async -> Void
	) async throws -> Value {
		do {
			let value = try await fromRemote()
			await saveToCache(value)
			return value
		} catch {
			if let cached = await fromCache() {
				return cached
			}
			throw error
		}
	}
}
