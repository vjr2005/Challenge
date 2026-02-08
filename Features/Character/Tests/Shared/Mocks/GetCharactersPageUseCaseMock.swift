import Foundation

@testable import ChallengeCharacter

final class GetCharactersPageUseCaseMock: GetCharactersPageUseCaseContract, @unchecked Sendable {
	var result: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed())
	private(set) var executeCallCount = 0
	private(set) var lastRequestedPage: Int?

	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage {
		executeCallCount += 1
		lastRequestedPage = page
		return try result.get()
	}
}
