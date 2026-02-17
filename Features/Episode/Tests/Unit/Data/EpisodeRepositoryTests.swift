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
	private let volatileDataSourceMock = EpisodeLocalDataSourceMock()
	private let persistenceDataSourceMock = EpisodeLocalDataSourceMock()
	private let sut: EpisodeRepository

	// MARK: - Initialization

	init() {
		sut = EpisodeRepository(
			remoteDataSource: remoteDataSourceMock,
			volatile: volatileDataSourceMock,
			persistence: persistenceDataSourceMock
		)
	}

	// MARK: - Remote Fetch

	@Test("Fetches from remote and maps to domain model")
	func fetchesFromRemoteAndMapsToDomainModel() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		let expected = EpisodeCharacterWithEpisodes.stub()
		remoteDataSourceMock.episodesResult = .success(remoteDTO)

		// When
		let value = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .noCache)

		// Then
		#expect(value == expected)
		#expect(remoteDataSourceMock.fetchEpisodesCallCount == 1)
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

	// MARK: - Cache Wiring

	@Test("Returns volatile cached value without calling remote")
	func returnsVolatileCachedValue() async throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		await volatileDataSourceMock.setEpisodesToReturn(dto)

		// When
		let value = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(value == EpisodeCharacterWithEpisodes.stub())
		#expect(remoteDataSourceMock.fetchEpisodesCallCount == 0)
	}

	@Test("Falls back to persistence when volatile misses")
	func fallsBackToPersistenceWhenVolatileMisses() async throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		await persistenceDataSourceMock.setEpisodesToReturn(dto)

		// When
		let value = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(value == EpisodeCharacterWithEpisodes.stub())
		#expect(remoteDataSourceMock.fetchEpisodesCallCount == 0)
		#expect(await volatileDataSourceMock.saveEpisodesCallCount == 1)
	}

	@Test("Saves to both caches after successful remote fetch")
	func savesToBothCachesAfterRemoteFetch() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .success(remoteDTO)

		// When
		_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(await volatileDataSourceMock.saveEpisodesCallCount == 1)
		#expect(await volatileDataSourceMock.lastSavedEpisodes == remoteDTO)
		#expect(await volatileDataSourceMock.lastSavedCharacterIdentifier == 1)
		#expect(await persistenceDataSourceMock.saveEpisodesCallCount == 1)
		#expect(await persistenceDataSourceMock.lastSavedEpisodes == remoteDTO)
		#expect(await persistenceDataSourceMock.lastSavedCharacterIdentifier == 1)
	}

	// MARK: - Error Handling

	@Test("Does not save to cache when remote fetch fails")
	func doesNotSaveToCacheOnRemoteError() async throws {
		// Given
		remoteDataSourceMock.episodesResult = .failure(APIError.invalidResponse)

		// When
		_ = try? await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(await volatileDataSourceMock.saveEpisodesCallCount == 0)
		#expect(await persistenceDataSourceMock.saveEpisodesCallCount == 0)
	}

	@Test("Maps generic error to loadFailed")
	func mapsGenericErrorToLoadFailed() async {
		// Given
		remoteDataSourceMock.episodesResult = .failure(GenericTestError.unknown)

		// When / Then
		await #expect(throws: EpisodeError.loadFailed()) {
			_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .noCache)
		}
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
