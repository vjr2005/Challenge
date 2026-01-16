import Foundation

@testable import ChallengeCharacter

/// Mock implementation of CharacterRepositoryContract for testing.
final class CharacterRepositoryMock: CharacterRepositoryContract, @unchecked Sendable {
	var result: Result<Character, Error> = .failure(NotConfiguredError.notConfigured)
	var charactersResult: Result<CharactersPage, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var getCharacterCallCount = 0
	private(set) var getCharactersCallCount = 0
	private(set) var lastRequestedIdentifier: Int?
	private(set) var lastRequestedPage: Int?

	func getCharacter(identifier: Int) async throws -> Character {
		getCharacterCallCount += 1
		lastRequestedIdentifier = identifier
		return try result.get()
	}

	func getCharacters(page: Int) async throws -> CharactersPage {
		getCharactersCallCount += 1
		lastRequestedPage = page
		return try charactersResult.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
