import Foundation

@testable import ChallengeCharacter

/// Mock implementation of GetCharactersUseCaseContract for testing.
final class GetCharactersUseCaseMock: GetCharactersUseCaseContract, @unchecked Sendable {
	var result: Result<CharactersPage, CharacterError> = .failure(.loadFailed)
	private(set) var executeCallCount = 0
	private(set) var lastRequestedPage: Int?
	private(set) var lastCachePolicy: CachePolicy?

	func execute(page: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> CharactersPage {
		executeCallCount += 1
		lastRequestedPage = page
		lastCachePolicy = cachePolicy
		return try result.get()
	}
}
