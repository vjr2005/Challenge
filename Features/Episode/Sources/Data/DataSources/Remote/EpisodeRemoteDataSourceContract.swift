import Foundation

protocol EpisodeRemoteDataSourceContract: Sendable {
	func fetchEpisodes(characterIdentifier: Int) async throws -> EpisodeCharacterWithEpisodesDTO
}
