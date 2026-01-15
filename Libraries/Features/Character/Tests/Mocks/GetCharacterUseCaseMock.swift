import Foundation

@testable import ChallengeCharacter

/// Mock implementation of GetCharacterUseCaseContract for testing.
final class GetCharacterUseCaseMock: GetCharacterUseCaseContract, @unchecked Sendable {
	var result: Result<Character, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var executeCallCount = 0
	private(set) var lastRequestedId: Int?

	func execute(id: Int) async throws -> Character {
		executeCallCount += 1
		lastRequestedId = id
		return try result.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
