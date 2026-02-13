import Testing

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct CachePolicyExecutorTests {
	// MARK: - Properties

	private let sut = CachePolicyExecutor()

	// MARK: - LocalFirst

	@Test("LocalFirst returns cached value when available")
	func localFirstReturnsCachedValue() async throws {
		// Given
		var remoteFetchCallCount = 0
		var saveToCacheCallCount = 0

		// When
		let value = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { remoteFetchCallCount += 1; return "99" },
			getFromCache: { "42" },
			saveToCache: { _ in saveToCacheCallCount += 1 },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 42)
		#expect(remoteFetchCallCount == 0)
		#expect(saveToCacheCallCount == 0)
	}

	@Test("LocalFirst fetches from remote when cache miss")
	func localFirstFetchesFromRemoteWhenCacheMiss() async throws {
		// Given
		var remoteFetchCallCount = 0

		// When
		let value = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { remoteFetchCallCount += 1; return "99" },
			getFromCache: { nil },
			saveToCache: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 99)
		#expect(remoteFetchCallCount == 1)
	}

	@Test("LocalFirst saves to cache after remote fetch")
	func localFirstSavesToCacheAfterRemoteFetch() async throws {
		// Given
		var savedValue: String?

		// When
		_ = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { "42" },
			getFromCache: { nil },
			saveToCache: { savedValue = $0 },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(savedValue == "42")
	}

	@Test("LocalFirst does not save to cache when remote fails")
	func localFirstDoesNotSaveWhenRemoteFails() async throws {
		// Given
		var saveToCacheCallCount = 0

		// When / Then
		await #expect(throws: TestError.remoteFailed) {
			try await sut.execute(
				policy: .localFirst,
				fetchFromRemote: { throw RawError.network },
				getFromCache: { nil },
				saveToCache: { (_: String) in saveToCacheCallCount += 1 },
				mapper: { Int($0) ?? 0 },
				errorMapper: { _ in TestError.remoteFailed }
			)
		}
		#expect(saveToCacheCallCount == 0)
	}

	@Test("LocalFirst applies mapper to cached value")
	func localFirstAppliesMapperToCachedValue() async throws {
		// When
		let value = try await sut.execute(
			policy: .localFirst,
			fetchFromRemote: { "ignored" },
			getFromCache: { "100" },
			saveToCache: { _ in },
			mapper: { (Int($0) ?? 0) * 2 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 200)
	}

	// MARK: - RemoteFirst

	@Test("RemoteFirst always fetches from remote")
	func remoteFirstAlwaysFetchesFromRemote() async throws {
		// Given
		var remoteFetchCallCount = 0

		// When
		let value = try await sut.execute(
			policy: .remoteFirst,
			fetchFromRemote: { remoteFetchCallCount += 1; return "99" },
			getFromCache: { "42" },
			saveToCache: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 99)
		#expect(remoteFetchCallCount == 1)
	}

	@Test("RemoteFirst saves to cache after remote fetch")
	func remoteFirstSavesToCacheAfterRemoteFetch() async throws {
		// Given
		var savedValue: String?

		// When
		_ = try await sut.execute(
			policy: .remoteFirst,
			fetchFromRemote: { "42" },
			getFromCache: { nil },
			saveToCache: { savedValue = $0 },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(savedValue == "42")
	}

	@Test("RemoteFirst falls back to cache on remote error")
	func remoteFirstFallsBackToCacheOnRemoteError() async throws {
		// When
		let value = try await sut.execute(
			policy: .remoteFirst,
			fetchFromRemote: { throw RawError.network },
			getFromCache: { "42" },
			saveToCache: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 42)
	}

	@Test("RemoteFirst throws when remote fails and cache is empty")
	func remoteFirstThrowsWhenRemoteFailsAndCacheEmpty() async {
		// When / Then
		await #expect(throws: TestError.remoteFailed) {
			try await sut.execute(
				policy: .remoteFirst,
				fetchFromRemote: { throw RawError.network },
				getFromCache: { nil },
				saveToCache: { (_: String) in },
				mapper: { Int($0) ?? 0 },
				errorMapper: { _ in TestError.remoteFailed }
			)
		}
	}

	// MARK: - NoCache

	@Test("NoCache fetches from remote only")
	func noCacheFetchesFromRemoteOnly() async throws {
		// Given
		var remoteFetchCallCount = 0

		// When
		let value = try await sut.execute(
			policy: .noCache,
			fetchFromRemote: { remoteFetchCallCount += 1; return "42" },
			getFromCache: { "ignored" },
			saveToCache: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(value == 42)
		#expect(remoteFetchCallCount == 1)
	}

	@Test("NoCache does not read from cache")
	func noCacheDoesNotReadFromCache() async throws {
		// Given
		var getFromCacheCallCount = 0

		// When
		_ = try await sut.execute(
			policy: .noCache,
			fetchFromRemote: { "42" },
			getFromCache: { getFromCacheCallCount += 1; return "99" },
			saveToCache: { _ in },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(getFromCacheCallCount == 0)
	}

	@Test("NoCache does not save to cache")
	func noCacheDoesNotSaveToCache() async throws {
		// Given
		var saveToCacheCallCount = 0

		// When
		_ = try await sut.execute(
			policy: .noCache,
			fetchFromRemote: { "42" },
			getFromCache: { nil },
			saveToCache: { (_: String) in saveToCacheCallCount += 1 },
			mapper: { Int($0) ?? 0 },
			errorMapper: { _ in TestError.remoteFailed }
		)

		// Then
		#expect(saveToCacheCallCount == 0)
	}

	@Test("NoCache propagates mapped error")
	func noCachePropagatesMappedError() async {
		// When / Then
		await #expect(throws: TestError.remoteFailed) {
			try await sut.execute(
				policy: .noCache,
				fetchFromRemote: { throw RawError.network },
				getFromCache: { nil },
				saveToCache: { (_: String) in },
				mapper: { Int($0) ?? 0 },
				errorMapper: { _ in TestError.remoteFailed }
			)
		}
	}

	// MARK: - Error Mapping

	@Test("Error mapper receives the original error")
	func errorMapperReceivesOriginalError() async {
		// Given
		var receivedError: (any Error)?

		// When / Then
		await #expect(throws: TestError.remoteFailed) {
			try await sut.execute(
				policy: .noCache,
				fetchFromRemote: { throw RawError.network },
				getFromCache: { nil },
				saveToCache: { (_: String) in },
				mapper: { Int($0) ?? 0 },
				errorMapper: { error in
					receivedError = error
					return TestError.remoteFailed
				}
			)
		}
		#expect(receivedError is RawError)
	}
}

// MARK: - Test Helpers

private enum TestError: Error, Equatable {
	case remoteFailed
}

private enum RawError: Error {
	case network
}
