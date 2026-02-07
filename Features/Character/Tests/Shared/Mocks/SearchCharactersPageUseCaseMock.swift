import Foundation

@testable import ChallengeCharacter

/// Mock implementation of SearchCharactersPageUseCaseContract for testing.
final class SearchCharactersPageUseCaseMock: SearchCharactersPageUseCaseContract, @unchecked Sendable {
	var result: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed)
	private(set) var executeCallCount = 0
	private(set) var lastRequestedPage: Int?
	private(set) var lastRequestedFilter: CharacterFilter?

	func execute(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
		executeCallCount += 1
		lastRequestedPage = page
		lastRequestedFilter = filter
		return try result.get()
	}
}
