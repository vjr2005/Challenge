import Foundation

protocol EpisodeLocalDataSourceContract: Actor {
	func getEpisodes(characterIdentifier: Int) async -> EpisodeCharacterWithEpisodesDTO?
	func saveEpisodes(_ episodes: EpisodeCharacterWithEpisodesDTO, characterIdentifier: Int) async
}
