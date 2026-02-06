import Foundation

@testable import ChallengeCharacter

/// Mock implementation of SearchCharactersUseCaseContract for testing.
final class SearchCharactersUseCaseMock: SearchCharactersUseCaseContract, @unchecked Sendable {
	var result: Result<CharactersPage, CharacterError> = .failure(.loadFailed)
	private(set) var executeCallCount = 0
	private(set) var lastRequestedPage: Int?
	private(set) var lastRequestedFilter: CharacterFilter?

	func execute(page: Int, filter: CharacterFilter) async throws(CharacterError) -> CharactersPage {
		executeCallCount += 1
		lastRequestedPage = page
		lastRequestedFilter = filter
		return try result.get()
	}
}
