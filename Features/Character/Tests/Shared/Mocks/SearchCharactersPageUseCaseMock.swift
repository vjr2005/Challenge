import Foundation

@testable import ChallengeCharacter

/// Mock implementation of SearchCharactersPageUseCaseContract for testing.
final class SearchCharactersPageUseCaseMock: SearchCharactersPageUseCaseContract, @unchecked Sendable {
	var result: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed())
	var onExecute: (() async -> Void)?
	private(set) var executeCallCount = 0
	private(set) var lastRequestedPage: Int?
	private(set) var lastRequestedFilter: CharacterFilter?

	func execute(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
		executeCallCount += 1
		lastRequestedPage = page
		lastRequestedFilter = filter
		await onExecute?()
		return try result.get()
	}
}
