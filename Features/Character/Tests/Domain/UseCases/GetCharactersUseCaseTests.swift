import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct GetCharactersUseCaseTests {
	@Test
	func returnsCharactersPageFromRepository() async throws {
		// Given
		let expected = CharactersPage.stub()
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.charactersResult = .success(expected)
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(page: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func callsRepositoryWithCorrectPage() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.charactersResult = .success(.stub())
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When
		_ = try await sut.execute(page: 5)

		// Then
		#expect(repositoryMock.getCharactersCallCount == 1)
		#expect(repositoryMock.lastRequestedPage == 5)
	}

	@Test
	func propagatesRepositoryError() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.charactersResult = .failure(.loadFailed)
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When / Then
		await #expect(throws: CharacterError.loadFailed) {
			_ = try await sut.execute(page: 1)
		}
	}
}
