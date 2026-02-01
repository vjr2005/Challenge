import Foundation

@testable import ChallengeCharacter

/// Mock implementation of GetCharacterUseCaseContract for testing.
final class GetCharacterUseCaseMock: GetCharacterUseCaseContract, @unchecked Sendable {
	var result: Result<Character, CharacterError> = .failure(.loadFailed)
	private(set) var executeCallCount = 0
	private(set) var lastRequestedIdentifier: Int?
	private(set) var lastCachePolicy: CachePolicy?

	func execute(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
		executeCallCount += 1
		lastRequestedIdentifier = identifier
		lastCachePolicy = cachePolicy
		return try result.get()
	}
}
