import Foundation

@testable import ChallengeCharacter

final class GetCharacterUseCaseMock: GetCharacterUseCaseContract, @unchecked Sendable {
	var result: Result<Character, CharacterError> = .failure(.loadFailed())
	private(set) var executeCallCount = 0
	private(set) var lastRequestedIdentifier: Int?

	func execute(identifier: Int) async throws(CharacterError) -> Character {
		executeCallCount += 1
		lastRequestedIdentifier = identifier
		return try result.get()
	}
}
