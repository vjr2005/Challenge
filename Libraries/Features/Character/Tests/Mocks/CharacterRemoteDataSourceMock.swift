import Foundation

@testable import ChallengeCharacter

/// Mock implementation of CharacterRemoteDataSourceContract for testing.
final class CharacterRemoteDataSourceMock: CharacterRemoteDataSourceContract, @unchecked Sendable {
	var result: Result<CharacterDTO, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var fetchCharacterCallCount = 0
	private(set) var lastFetchedId: Int?

	func fetchCharacter(id: Int) async throws -> CharacterDTO {
		fetchCharacterCallCount += 1
		lastFetchedId = id
		return try result.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
