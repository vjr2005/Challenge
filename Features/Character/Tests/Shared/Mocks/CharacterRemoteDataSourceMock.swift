import Foundation

@testable import ChallengeCharacter

/// Mock implementation of CharacterRemoteDataSourceContract for testing.
final class CharacterRemoteDataSourceMock: CharacterRemoteDataSourceContract, @unchecked Sendable {
	var result: Result<CharacterDTO, Error> = .failure(NotConfiguredError.notConfigured)
	var charactersResult: Result<CharactersResponseDTO, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var fetchCharacterCallCount = 0
	private(set) var fetchCharactersCallCount = 0
	private(set) var lastFetchedIdentifier: Int?
	private(set) var lastFetchedPage: Int?
	private(set) var lastFetchedFilter: CharacterFilter?

	func fetchCharacter(identifier: Int) async throws -> CharacterDTO {
		fetchCharacterCallCount += 1
		lastFetchedIdentifier = identifier
		return try result.get()
	}

	func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> CharactersResponseDTO {
		fetchCharactersCallCount += 1
		lastFetchedPage = page
		lastFetchedFilter = filter
		return try charactersResult.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
