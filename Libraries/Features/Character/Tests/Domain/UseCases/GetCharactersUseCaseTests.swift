import Foundation
import Testing

@testable import ChallengeCharacter

struct GetCharactersUseCaseTests {
	@Test
	func returnsCharactersPageFromRepository() async throws {
		// Given
		let expected = CharactersPage.stub()
		let repository = CharacterRepositoryMock()
		repository.charactersResult = .success(expected)
		let sut = GetCharactersUseCase(repository: repository)

		// When
		let value = try await sut.execute(page: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func callsRepositoryWithCorrectPage() async throws {
		// Given
		let repository = CharacterRepositoryMock()
		repository.charactersResult = .success(.stub())
		let sut = GetCharactersUseCase(repository: repository)

		// When
		_ = try await sut.execute(page: 5)

		// Then
		#expect(repository.getCharactersCallCount == 1)
		#expect(repository.lastRequestedPage == 5)
	}

	@Test
	func propagatesRepositoryError() async throws {
		// Given
		let repository = CharacterRepositoryMock()
		repository.charactersResult = .failure(TestError.network)
		let sut = GetCharactersUseCase(repository: repository)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.execute(page: 1)
		}
	}
}

private enum TestError: Error {
	case network
}
