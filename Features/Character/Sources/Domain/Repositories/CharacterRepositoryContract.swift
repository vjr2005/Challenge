import ChallengeCore
import Foundation

nonisolated protocol CharacterRepositoryContract: Sendable {
	@concurrent func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
}
