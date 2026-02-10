import ChallengeCore
import Foundation

protocol EpisodeRepositoryContract: Sendable {
	func getEpisodes(characterIdentifier: Int, cachePolicy: CachePolicy) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes
}
