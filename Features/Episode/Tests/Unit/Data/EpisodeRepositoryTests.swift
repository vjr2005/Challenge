import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworking
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeRepositoryTests {
	// MARK: - Properties

	private let remoteDataSourceMock = EpisodeRemoteDataSourceMock()
	private let memoryDataSourceMock = EpisodeMemoryDataSourceMock()
	private let sut: EpisodeRepository

	// MARK: - Initialization

	init() {
		sut = EpisodeRepository(
			remoteDataSource: remoteDataSourceMock,
			memoryDataSource: memoryDataSourceMock
		)
	}

	// MARK: - LocalFirst Policy

	@Test("LocalFirst returns cached episodes when available in memory")
	func localFirstReturnsCachedEpisodesWhenAvailable() async throws {
		// Given
		let cachedDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		let expected = EpisodeCharacterWithEpisodes.stub()
		memoryDataSourceMock.episodesToReturn = cachedDTO

		// When
		let value = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(value == expected)
	}

	@Test("LocalFirst does not call remote data source when cache hit")
	func localFirstDoesNotCallRemoteWhenCacheHit() async throws {
		// Given
		let cachedDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		memoryDataSourceMock.episodesToReturn = cachedDTO

		// When
		_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(remoteDataSourceMock.fetchEpisodesCallCount == 0)
	}

	@Test("LocalFirst fetches from remote data source when cache miss")
	func localFirstFetchesFromRemoteWhenCacheMiss() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		let expected = EpisodeCharacterWithEpisodes.stub()
		remoteDataSourceMock.episodesResult = .success(remoteDTO)

		// When
		let value = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(value == expected)
		#expect(remoteDataSourceMock.fetchEpisodesCallCount == 1)
	}

	@Test("LocalFirst saves episodes to cache after remote fetch")
	func localFirstSavesToCacheAfterRemoteFetch() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .success(remoteDTO)

		// When
		_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(memoryDataSourceMock.saveEpisodesCallCount == 1)
		#expect(memoryDataSourceMock.lastSavedEpisodes == remoteDTO)
		#expect(memoryDataSourceMock.lastSavedCharacterIdentifier == 1)
	}

	// MARK: - RemoteFirst Policy

	@Test("RemoteFirst always fetches from remote data source")
	func remoteFirstAlwaysFetchesFromRemote() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .success(remoteDTO)
		memoryDataSourceMock.episodesToReturn = remoteDTO

		// When
		_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .remoteFirst)

		// Then
		#expect(remoteDataSourceMock.fetchEpisodesCallCount == 1)
	}

	@Test("RemoteFirst saves episodes to cache after remote fetch")
	func remoteFirstSavesToCacheAfterRemoteFetch() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .success(remoteDTO)

		// When
		_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .remoteFirst)

		// Then
		#expect(memoryDataSourceMock.saveEpisodesCallCount == 1)
		#expect(memoryDataSourceMock.lastSavedEpisodes == remoteDTO)
	}

	@Test("RemoteFirst falls back to cache on remote error")
	func remoteFirstFallsBackToCacheOnRemoteError() async throws {
		// Given
		let cachedDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .failure(APIError.invalidResponse)
		memoryDataSourceMock.episodesToReturn = cachedDTO

		// When
		let value = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .remoteFirst)

		// Then
		#expect(value == EpisodeCharacterWithEpisodes.stub())
	}

	@Test("RemoteFirst throws error when remote fails and no cache")
	func remoteFirstThrowsErrorWhenRemoteFailsAndNoCache() async throws {
		// Given
		remoteDataSourceMock.episodesResult = .failure(APIError.invalidResponse)

		// When / Then
		await #expect(throws: EpisodeError.loadFailed()) {
			_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .remoteFirst)
		}
	}

	// MARK: - NoCache Policy

	@Test("NoCache policy only fetches from remote")
	func noCachePolicyOnlyFetchesFromRemote() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .success(remoteDTO)

		// When
		let value = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .noCache)

		// Then
		#expect(value == EpisodeCharacterWithEpisodes.stub())
		#expect(remoteDataSourceMock.fetchEpisodesCallCount == 1)
	}

	@Test("NoCache policy does not save to cache")
	func noCachePolicyDoesNotSaveToCache() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .success(remoteDTO)

		// When
		_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .noCache)

		// Then
		#expect(memoryDataSourceMock.saveEpisodesCallCount == 0)
	}

	@Test("NoCache policy does not check cache")
	func noCachePolicyDoesNotCheckCache() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .success(remoteDTO)
		memoryDataSourceMock.episodesToReturn = remoteDTO

		// When
		_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .noCache)

		// Then
		#expect(memoryDataSourceMock.getEpisodesCallCount == 0)
	}

	// MARK: - Error Handling

	@Test("Does not save to cache when remote fetch fails")
	func doesNotSaveToCacheOnRemoteError() async throws {
		// Given
		remoteDataSourceMock.episodesResult = .failure(APIError.invalidResponse)

		// When
		_ = try? await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(memoryDataSourceMock.saveEpisodesCallCount == 0)
	}

	@Test("Maps generic error to loadFailed")
	func mapsGenericErrorToLoadFailed() async throws {
		// Given
		remoteDataSourceMock.episodesResult = .failure(GenericTestError.unknown)

		// When / Then
		await #expect(throws: EpisodeError.loadFailed()) {
			_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .noCache)
		}
	}

	@Test("Passes correct character identifier to remote data source")
	func passesCorrectCharacterIdentifier() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .success(remoteDTO)

		// When
		_ = try await sut.getEpisodes(characterIdentifier: 42, cachePolicy: .noCache)

		// Then
		#expect(remoteDataSourceMock.lastFetchedCharacterIdentifier == 42)
	}
}

// MARK: - Private

private extension EpisodeRepositoryTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}

private enum GenericTestError: Error {
	case unknown
}
