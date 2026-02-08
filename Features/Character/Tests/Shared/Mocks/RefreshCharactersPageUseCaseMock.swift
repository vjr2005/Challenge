import Foundation

@testable import ChallengeCharacter

final class RefreshCharactersPageUseCaseMock: RefreshCharactersPageUseCaseContract, @unchecked Sendable {
	var result: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed())
	var onExecute: (() -> Void)?
	private(set) var executeCallCount = 0
	private(set) var lastRequestedPage: Int?

	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage {
		executeCallCount += 1
		lastRequestedPage = page
		onExecute?()
		return try result.get()
	}
}
