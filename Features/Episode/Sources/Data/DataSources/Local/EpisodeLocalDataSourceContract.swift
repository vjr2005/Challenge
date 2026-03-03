protocol EpisodeLocalDataSourceContract: Actor {
	func getEpisodes(characterIdentifier: Int) -> EpisodeCharacterWithEpisodesDTO?
	func saveEpisodes(_ episodes: EpisodeCharacterWithEpisodesDTO, characterIdentifier: Int)
}
