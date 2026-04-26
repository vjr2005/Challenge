import Testing

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct CachePolicyTests {
	// MARK: - LocalFirst

	@Test("LocalFirst returns cached value when available")
	func localFirstReturnsCachedValue() async throws {
		// Given
		var remoteFetchCallCount = 0
		var saveToCacheCallCount = 0

		// When
		let value = try await CachePolicy.localFirst.fetch(
			fromRemote: { remoteFetchCallCount += 1; return "99" },
			fromCache: { "42" },
			saveToCache: { _ in saveToCacheCallCount += 1 }
		)

		// Then
		#expect(value == "42")
		#expect(remoteFetchCallCount == 0)
		#expect(saveToCacheCallCount == 0)
	}

	@Test("LocalFirst fetches from remote when cache miss")
	func localFirstFetchesFromRemoteWhenCacheMiss() async throws {
		// Given
		var remoteFetchCallCount = 0

		// When
		let value = try await CachePolicy.localFirst.fetch(
			fromRemote: { remoteFetchCallCount += 1; return "99" },
			fromCache: { nil },
			saveToCache: { _ in }
		)

		// Then
		#expect(value == "99")
		#expect(remoteFetchCallCount == 1)
	}

	@Test("LocalFirst saves to cache after remote fetch")
	func localFirstSavesToCacheAfterRemoteFetch() async throws {
		// Given
		var savedValue: String?

		// When
		_ = try await CachePolicy.localFirst.fetch(
			fromRemote: { "42" },
			fromCache: { nil },
			saveToCache: { savedValue = $0 }
		)

		// Then
		#expect(savedValue == "42")
	}

	@Test("LocalFirst does not save to cache when remote fails")
	func localFirstDoesNotSaveWhenRemoteFails() async throws {
		// Given
		var saveToCacheCallCount = 0

		// When / Then
		await #expect(throws: RawError.network) {
			try await CachePolicy.localFirst.fetch(
				fromRemote: { throw RawError.network },
				fromCache: { nil },
				saveToCache: { (_: String) in saveToCacheCallCount += 1 }
			)
		}
		#expect(saveToCacheCallCount == 0)
	}

	// MARK: - RemoteFirst

	@Test("RemoteFirst always fetches from remote")
	func remoteFirstAlwaysFetchesFromRemote() async throws {
		// Given
		var remoteFetchCallCount = 0

		// When
		let value = try await CachePolicy.remoteFirst.fetch(
			fromRemote: { remoteFetchCallCount += 1; return "99" },
			fromCache: { "42" },
			saveToCache: { _ in }
		)

		// Then
		#expect(value == "99")
		#expect(remoteFetchCallCount == 1)
	}

	@Test("RemoteFirst saves to cache after remote fetch")
	func remoteFirstSavesToCacheAfterRemoteFetch() async throws {
		// Given
		var savedValue: String?

		// When
		_ = try await CachePolicy.remoteFirst.fetch(
			fromRemote: { "42" },
			fromCache: { nil },
			saveToCache: { savedValue = $0 }
		)

		// Then
		#expect(savedValue == "42")
	}

	@Test("RemoteFirst falls back to cache on remote error")
	func remoteFirstFallsBackToCacheOnRemoteError() async throws {
		// When
		let value = try await CachePolicy.remoteFirst.fetch(
			fromRemote: { throw RawError.network },
			fromCache: { "42" },
			saveToCache: { _ in }
		)

		// Then
		#expect(value == "42")
	}

	@Test("RemoteFirst throws when remote fails and cache is empty")
	func remoteFirstThrowsWhenRemoteFailsAndCacheEmpty() async {
		// When / Then
		await #expect(throws: RawError.network) {
			try await CachePolicy.remoteFirst.fetch(
				fromRemote: { throw RawError.network },
				fromCache: { nil },
				saveToCache: { (_: String) in }
			)
		}
	}

	// MARK: - NoCache

	@Test("NoCache fetches from remote only")
	func noCacheFetchesFromRemoteOnly() async throws {
		// Given
		var remoteFetchCallCount = 0

		// When
		let value = try await CachePolicy.noCache.fetch(
			fromRemote: { remoteFetchCallCount += 1; return "42" },
			fromCache: { "ignored" },
			saveToCache: { _ in }
		)

		// Then
		#expect(value == "42")
		#expect(remoteFetchCallCount == 1)
	}

	@Test("NoCache does not read from cache")
	func noCacheDoesNotReadFromCache() async throws {
		// Given
		var getFromCacheCallCount = 0

		// When
		_ = try await CachePolicy.noCache.fetch(
			fromRemote: { "42" },
			fromCache: { getFromCacheCallCount += 1; return "99" },
			saveToCache: { _ in }
		)

		// Then
		#expect(getFromCacheCallCount == 0)
	}

	@Test("NoCache does not save to cache")
	func noCacheDoesNotSaveToCache() async throws {
		// Given
		var saveToCacheCallCount = 0

		// When
		_ = try await CachePolicy.noCache.fetch(
			fromRemote: { "42" },
			fromCache: { nil },
			saveToCache: { (_: String) in saveToCacheCallCount += 1 }
		)

		// Then
		#expect(saveToCacheCallCount == 0)
	}

	@Test("NoCache propagates error")
	func noCachePropagatesError() async {
		// When / Then
		await #expect(throws: RawError.network) {
			try await CachePolicy.noCache.fetch(
				fromRemote: { throw RawError.network },
				fromCache: { nil },
				saveToCache: { (_: String) in }
			)
		}
	}
}

// MARK: - Test Helpers

private enum RawError: Error, Equatable {
	case network
}
