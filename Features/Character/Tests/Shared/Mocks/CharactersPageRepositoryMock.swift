import ChallengeCore
import Foundation

@testable import ChallengeCharacter

final class CharactersPageRepositoryMock: CharactersPageRepositoryContract, @unchecked Sendable {
	var charactersResult: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed())
	var searchResult: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed())
	private(set) var getCharactersPageCallCount = 0
	private(set) var searchCharactersPageCallCount = 0
	private(set) var lastRequestedPage: Int?
	private(set) var lastSearchedPage: Int?
	private(set) var lastSearchedFilter: CharacterFilter?
	private(set) var lastCharactersCachePolicy: CachePolicy?

	func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage {
		getCharactersPageCallCount += 1
		lastRequestedPage = page
		lastCharactersCachePolicy = cachePolicy
		return try charactersResult.get()
	}

	func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
		searchCharactersPageCallCount += 1
		lastSearchedPage = page
		lastSearchedFilter = filter
		return try searchResult.get()
	}
}
