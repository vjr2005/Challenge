import Foundation

protocol EpisodeLocalDataSourceContract: Sendable {
	func getEpisodes(characterIdentifier: Int) async -> EpisodeCharacterWithEpisodesDTO?
	func saveEpisodes(_ episodes: EpisodeCharacterWithEpisodesDTO, characterIdentifier: Int) async
}
