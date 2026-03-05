import ChallengeCore
import Foundation

@testable import ChallengeEpisode

nonisolated final class EpisodeRepositoryMock: EpisodeRepositoryContract, @unchecked Sendable {
	var result: Result<EpisodeCharacterWithEpisodes, EpisodeError> = .failure(.loadFailed())
	private(set) var getEpisodesCallCount = 0
	private(set) var lastRequestedCharacterIdentifier: Int?
	private(set) var lastCachePolicy: CachePolicy?

	@concurrent func getEpisodes(characterIdentifier: Int, cachePolicy: CachePolicy) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		getEpisodesCallCount += 1
		lastRequestedCharacterIdentifier = characterIdentifier
		lastCachePolicy = cachePolicy
		return try result.get()
	}
}
