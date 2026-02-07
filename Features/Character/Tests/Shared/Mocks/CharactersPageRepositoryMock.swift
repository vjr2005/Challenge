import ChallengeCore
import Foundation

@testable import ChallengeCharacter

final class CharactersPageRepositoryMock: CharactersPageRepositoryContract, @unchecked Sendable {
	var charactersResult: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed)
	var searchResult: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed)
	private(set) var getCharactersCallCount = 0
	private(set) var searchCharactersCallCount = 0
	private(set) var lastRequestedPage: Int?
	private(set) var lastSearchedPage: Int?
	private(set) var lastSearchedFilter: CharacterFilter?
	private(set) var lastCharactersCachePolicy: CachePolicy?

	func getCharacters(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage {
		getCharactersCallCount += 1
		lastRequestedPage = page
		lastCharactersCachePolicy = cachePolicy
		return try charactersResult.get()
	}

	func searchCharacters(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
		searchCharactersCallCount += 1
		lastSearchedPage = page
		lastSearchedFilter = filter
		return try searchResult.get()
	}
}
