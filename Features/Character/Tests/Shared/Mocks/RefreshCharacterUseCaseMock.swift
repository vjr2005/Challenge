import Foundation

@testable import ChallengeCharacter

final class RefreshCharacterUseCaseMock: RefreshCharacterUseCaseContract, @unchecked Sendable {
	var result: Result<Character, CharacterError> = .failure(.loadFailed())
	var onExecute: (() -> Void)?
	private(set) var executeCallCount = 0
	private(set) var lastRequestedIdentifier: Int?

	func execute(identifier: Int) async throws(CharacterError) -> Character {
		executeCallCount += 1
		lastRequestedIdentifier = identifier
		onExecute?()
		return try result.get()
	}
}
