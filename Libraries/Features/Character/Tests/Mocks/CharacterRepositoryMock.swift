import Foundation

@testable import ChallengeCharacter

/// Mock implementation of CharacterRepositoryContract for testing.
final class CharacterRepositoryMock: CharacterRepositoryContract, @unchecked Sendable {
	var result: Result<Character, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var getCharacterCallCount = 0
	private(set) var lastRequestedId: Int?

	func getCharacter(id: Int) async throws -> Character {
		getCharacterCallCount += 1
		lastRequestedId = id
		return try result.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
