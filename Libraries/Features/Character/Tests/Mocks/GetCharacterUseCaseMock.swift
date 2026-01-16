import Foundation

@testable import ChallengeCharacter

/// Mock implementation of GetCharacterUseCaseContract for testing.
final class GetCharacterUseCaseMock: GetCharacterUseCaseContract, @unchecked Sendable {
	var result: Result<Character, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var executeCallCount = 0
	private(set) var lastRequestedIdentifier: Int?

	func execute(identifier: Int) async throws -> Character {
		executeCallCount += 1
		lastRequestedIdentifier = identifier
		return try result.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
