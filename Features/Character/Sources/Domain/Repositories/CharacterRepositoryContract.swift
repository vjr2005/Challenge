import ChallengeCore
import Foundation

protocol CharacterRepositoryContract: Sendable {
	func getCharacterDetail(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
}
