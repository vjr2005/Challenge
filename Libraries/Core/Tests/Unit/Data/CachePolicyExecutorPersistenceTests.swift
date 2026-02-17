import Testing

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct CachePolicyExecutorPersistenceTests {
	// MARK: - Properties

	private let sut = CachePolicyExecutor()

	// MARK: - LocalFirst with Persistence

	@Test("LocalFirst returns L1 cache and skips persistence")
	func localFirstReturnsL1CacheAndSkipsPersistence() async throws {
		// Given
		var getFromPersistenceCallCount = 0
		var remoteFetchCallCount = 0

		// When
		let value = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { remoteFetchCallCount += 1; return "99" },
			getFromVolatile: { "42" },
			getFromPersistence: { getFromPersistenceCallCount += 1; return "77" },
			saveToVolatile: { _ in },
			saveToPersistence: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 42)
		#expect(getFromPersistenceCallCount == 0)
		#expect(remoteFetchCallCount == 0)
	}

	@Test("LocalFirst falls back to persistence on L1 cache miss")
	func localFirstFallsBackToPersistenceOnCacheMiss() async throws {
		// Given
		var remoteFetchCallCount = 0

		// When
		let value = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { remoteFetchCallCount += 1; return "99" },
			getFromVolatile: { nil },
			getFromPersistence: { "77" },
			saveToVolatile: { _ in },
			saveToPersistence: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 77)
		#expect(remoteFetchCallCount == 0)
	}

	@Test("LocalFirst promotes persistence hit to L1 cache")
	func localFirstPromotesPersistenceHitToCache() async throws {
		// Given
		var savedToCache: String?

		// When
		_ = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { "99" },
			getFromVolatile: { nil },
			getFromPersistence: { "77" },
			saveToVolatile: { savedToCache = $0 },
			saveToPersistence: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(savedToCache == "77")
	}

	@Test("LocalFirst fetches from remote when both cache and persistence miss")
	func localFirstFetchesFromRemoteWhenBothMiss() async throws {
		// Given
		var remoteFetchCallCount = 0

		// When
		let value = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { remoteFetchCallCount += 1; return "99" },
			getFromVolatile: { nil },
			getFromPersistence: { nil },
			saveToVolatile: { _ in },
			saveToPersistence: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 99)
		#expect(remoteFetchCallCount == 1)
	}

	@Test("LocalFirst saves to both cache and persistence after remote fetch")
	func localFirstSavesToBothAfterRemoteFetch() async throws {
		// Given
		var savedToCache: String?
		var savedToPersistence: String?

		// When
		_ = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { "42" },
			getFromVolatile: { nil },
			getFromPersistence: { nil },
			saveToVolatile: { savedToCache = $0 },
			saveToPersistence: { savedToPersistence = $0 },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(savedToCache == "42")
		#expect(savedToPersistence == "42")
	}

	@Test("LocalFirst does not save to persistence on persistence hit")
	func localFirstDoesNotSaveToPersistenceOnPersistenceHit() async throws {
		// Given
		var saveToPersistenceCallCount = 0

		// When
		_ = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { "99" },
			getFromVolatile: { nil },
			getFromPersistence: { "77" },
			saveToVolatile: { _ in },
			saveToPersistence: { _ in saveToPersistenceCallCount += 1 },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(saveToPersistenceCallCount == 0)
	}

	// MARK: - RemoteFirst with Persistence

	@Test("RemoteFirst saves to both cache and persistence after remote fetch")
	func remoteFirstSavesToBothAfterRemoteFetch() async throws {
		// Given
		var savedToCache: String?
		var savedToPersistence: String?

		// When
		_ = try await sut.execute(
			policy: .remoteFirst,
			fetchFromRemote: { "42" },
			getFromVolatile: { nil },
			getFromPersistence: { nil },
			saveToVolatile: { savedToCache = $0 },
			saveToPersistence: { savedToPersistence = $0 },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(savedToCache == "42")
		#expect(savedToPersistence == "42")
	}

	@Test("RemoteFirst falls back to L1 cache on remote error")
	func remoteFirstFallsBackToL1CacheOnRemoteError() async throws {
		// Given
		var getFromPersistenceCallCount = 0

		// When
		let value = try await sut.execute(
			policy: .remoteFirst,
			fetchFromRemote: { throw RawError.network },
			getFromVolatile: { "42" },
			getFromPersistence: { getFromPersistenceCallCount += 1; return "77" },
			saveToVolatile: { _ in },
			saveToPersistence: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 42)
		#expect(getFromPersistenceCallCount == 0)
	}

	@Test("RemoteFirst falls back to persistence when remote fails and L1 cache misses")
	func remoteFirstFallsBackToPersistenceWhenRemoteAndCacheMiss() async throws {
		// When
		let value = try await sut.execute(
			policy: .remoteFirst,
			fetchFromRemote: { throw RawError.network },
			getFromVolatile: { nil },
			getFromPersistence: { "77" },
			saveToVolatile: { _ in },
			saveToPersistence: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 77)
	}

	@Test("RemoteFirst promotes persistence hit to L1 cache on remote error")
	func remoteFirstPromotesPersistenceHitToCacheOnRemoteError() async throws {
		// Given
		var savedToCache: String?

		// When
		_ = try await sut.execute(
			policy: .remoteFirst,
			fetchFromRemote: { throw RawError.network },
			getFromVolatile: { nil },
			getFromPersistence: { "77" },
			saveToVolatile: { savedToCache = $0 },
			saveToPersistence: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(savedToCache == "77")
	}

	@Test("RemoteFirst throws when remote, L1 cache and persistence all fail")
	func remoteFirstThrowsWhenAllSourcesFail() async {
		// When / Then
		await #expect(throws: TestError.remoteFailed) {
			try await sut.execute(
				policy: .remoteFirst,
				fetchFromRemote: { throw RawError.network },
				getFromVolatile: { nil },
				getFromPersistence: { nil },
				saveToVolatile: { (_: String) in },
				saveToPersistence: { (_: String) in },
				mapper: { Int($0) ?? 0 },
				errorMapper: { _ in TestError.remoteFailed }
			)
		}
	}
}

// MARK: - Test Helpers

private enum TestError: Error, Equatable {
	case remoteFailed
}

private enum RawError: Error {
	case network
}
