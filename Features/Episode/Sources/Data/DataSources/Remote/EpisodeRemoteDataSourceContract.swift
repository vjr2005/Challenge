import Foundation

nonisolated protocol EpisodeRemoteDataSourceContract: Sendable {
	@concurrent func fetchEpisodes(characterIdentifier: Int) async throws -> EpisodeCharacterWithEpisodesDTO
}
