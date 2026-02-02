import Foundation

@testable import ChallengeCharacter

final class RefreshCharactersUseCaseMock: RefreshCharactersUseCaseContract, @unchecked Sendable {
	var result: Result<CharactersPage, CharacterError> = .failure(.loadFailed)
	private(set) var executeCallCount = 0
	private(set) var lastRequestedPage: Int?

	func execute(page: Int) async throws(CharacterError) -> CharactersPage {
		executeCallCount += 1
		lastRequestedPage = page
		return try result.get()
	}
}
