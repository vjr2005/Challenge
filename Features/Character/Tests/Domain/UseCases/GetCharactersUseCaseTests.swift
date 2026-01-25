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
		repositoryMock.charactersResult = .failure(TestError.network)
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.execute(page: 1)
		}
	}
}

private enum TestError: Error {
	case network
}
