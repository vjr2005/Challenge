import Foundation

actor EpisodeMemoryDataSource: EpisodeLocalDataSourceContract {
	private var storage: [Int: EpisodeCharacterWithEpisodesDTO] = [:]

	func getEpisodes(characterIdentifier: Int) -> EpisodeCharacterWithEpisodesDTO? {
		storage[characterIdentifier]
	}

	func saveEpisodes(_ episodes: EpisodeCharacterWithEpisodesDTO, characterIdentifier: Int) {
		storage[characterIdentifier] = episodes
	}
}
