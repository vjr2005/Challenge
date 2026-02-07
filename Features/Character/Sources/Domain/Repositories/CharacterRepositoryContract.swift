import ChallengeCore
import Foundation

protocol CharacterRepositoryContract: Sendable {
	func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
}
