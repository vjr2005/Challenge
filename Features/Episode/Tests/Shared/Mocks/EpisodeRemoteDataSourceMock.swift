import Foundation

@testable import ChallengeEpisode

final class EpisodeRemoteDataSourceMock: EpisodeRemoteDataSourceContract, @unchecked Sendable {
	var episodesResult: Result<EpisodeCharacterWithEpisodesDTO, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var fetchEpisodesCallCount = 0
	private(set) var lastFetchedCharacterIdentifier: Int?

	func fetchEpisodes(characterIdentifier: Int) async throws -> EpisodeCharacterWithEpisodesDTO {
		fetchEpisodesCallCount += 1
		lastFetchedCharacterIdentifier = characterIdentifier
		return try episodesResult.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
