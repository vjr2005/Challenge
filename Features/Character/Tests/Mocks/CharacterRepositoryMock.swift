import Foundation

@testable import ChallengeCharacter

/// Mock implementation of CharacterRepositoryContract for testing.
final class CharacterRepositoryMock: CharacterRepositoryContract, @unchecked Sendable {
	var result: Result<Character, CharacterError> = .failure(.loadFailed)
	var charactersResult: Result<CharactersPage, CharacterError> = .failure(.loadFailed)
	var searchResult: Result<CharactersPage, CharacterError> = .failure(.loadFailed)
	private(set) var getCharacterCallCount = 0
	private(set) var getCharactersCallCount = 0
	private(set) var searchCharactersCallCount = 0
	private(set) var lastRequestedIdentifier: Int?
	private(set) var lastRequestedPage: Int?
	private(set) var lastSearchedPage: Int?
	private(set) var lastSearchedQuery: String?

	func getCharacter(identifier: Int) async throws(CharacterError) -> Character {
		getCharacterCallCount += 1
		lastRequestedIdentifier = identifier
		return try result.get()
	}

	func getCharacters(page: Int) async throws(CharacterError) -> CharactersPage {
		getCharactersCallCount += 1
		lastRequestedPage = page
		return try charactersResult.get()
	}

	func searchCharacters(page: Int, query: String) async throws(CharacterError) -> CharactersPage {
		searchCharactersCallCount += 1
		lastSearchedPage = page
		lastSearchedQuery = query
		return try searchResult.get()
	}
}
