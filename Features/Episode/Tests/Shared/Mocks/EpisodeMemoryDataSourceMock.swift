import Foundation

@testable import ChallengeEpisode

final class EpisodeMemoryDataSourceMock: EpisodeLocalDataSourceContract, @unchecked Sendable {
	// MARK: - Configurable Returns

	var episodesToReturn: EpisodeCharacterWithEpisodesDTO?

	// MARK: - Call Tracking

	private(set) var getEpisodesCallCount = 0
	private(set) var lastGetCharacterIdentifier: Int?

	private(set) var saveEpisodesCallCount = 0
	private(set) var lastSavedEpisodes: EpisodeCharacterWithEpisodesDTO?
	private(set) var lastSavedCharacterIdentifier: Int?

	// MARK: - EpisodeLocalDataSourceContract

	func getEpisodes(characterIdentifier: Int) -> EpisodeCharacterWithEpisodesDTO? {
		getEpisodesCallCount += 1
		lastGetCharacterIdentifier = characterIdentifier
		return episodesToReturn
	}

	func saveEpisodes(_ episodes: EpisodeCharacterWithEpisodesDTO, characterIdentifier: Int) {
		saveEpisodesCallCount += 1
		lastSavedEpisodes = episodes
		lastSavedCharacterIdentifier = characterIdentifier
	}
}
