import ChallengeCore
import Foundation

@testable import ChallengeCharacter

final class CharacterRepositoryMock: CharacterRepositoryContract, @unchecked Sendable {
	var result: Result<Character, CharacterError> = .failure(.loadFailed())
	private(set) var getCharacterCallCount = 0
	private(set) var lastRequestedIdentifier: Int?
	private(set) var lastCharacterCachePolicy: CachePolicy?

	func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
		getCharacterCallCount += 1
		lastRequestedIdentifier = identifier
		lastCharacterCachePolicy = cachePolicy
		return try result.get()
	}
}
