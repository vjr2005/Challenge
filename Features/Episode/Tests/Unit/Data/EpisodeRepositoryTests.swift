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

	@Test("Saves to cache after successful remote fetch")
	func savesToCacheAfterRemoteFetch() async throws {
		// Given
		let remoteDTO: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		remoteDataSourceMock.episodesResult = .success(remoteDTO)

		// When
		_ = try await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(await memoryDataSourceMock.saveEpisodesCallCount == 1)
		#expect(await memoryDataSourceMock.lastSavedEpisodes == remoteDTO)
		#expect(await memoryDataSourceMock.lastSavedCharacterIdentifier == 1)
	}

	// MARK: - Error Handling

	@Test("Does not save to cache when remote fetch fails")
	func doesNotSaveToCacheOnRemoteError() async throws {
		// Given
		remoteDataSourceMock.episodesResult = .failure(APIError.invalidResponse)

		// When
		_ = try? await sut.getEpisodes(characterIdentifier: 1, cachePolicy: .localFirst)

		// Then
		#expect(await memoryDataSourceMock.saveEpisodesCallCount == 0)
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
