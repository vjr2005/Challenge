import Foundation

@testable import ChallengeEpisode

nonisolated final class EpisodeRemoteDataSourceMock: EpisodeRemoteDataSourceContract, @unchecked Sendable {
	var episodesResult: Result<EpisodeCharacterWithEpisodesDTO, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var fetchEpisodesCallCount = 0
	private(set) var lastFetchedCharacterIdentifier: Int?

	@concurrent func fetchEpisodes(characterIdentifier: Int) async throws -> EpisodeCharacterWithEpisodesDTO {
		fetchEpisodesCallCount += 1
		lastFetchedCharacterIdentifier = characterIdentifier
		return try episodesResult.get()
	}

	// MARK: - Reset

	func reset() {
		fetchEpisodesCallCount = 0
		lastFetchedCharacterIdentifier = nil
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
