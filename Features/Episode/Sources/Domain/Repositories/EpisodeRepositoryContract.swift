import ChallengeCore
import Foundation

nonisolated protocol EpisodeRepositoryContract: Sendable {
	@concurrent func getEpisodes(characterIdentifier: Int, cachePolicy: CachePolicy) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes
}
