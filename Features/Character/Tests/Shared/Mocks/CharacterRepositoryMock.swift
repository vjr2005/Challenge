import ChallengeCore
import Foundation

@testable import ChallengeCharacter

final class CharacterRepositoryMock: CharacterRepositoryContract, @unchecked Sendable {
	var result: Result<Character, CharacterError> = .failure(.loadFailed)
	private(set) var getCharacterDetailCallCount = 0
	private(set) var lastRequestedIdentifier: Int?
	private(set) var lastCharacterDetailCachePolicy: CachePolicy?

	func getCharacterDetail(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
		getCharacterDetailCallCount += 1
		lastRequestedIdentifier = identifier
		lastCharacterDetailCachePolicy = cachePolicy
		return try result.get()
	}
}
