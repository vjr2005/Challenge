import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct GetCharacterUseCaseTests {
	@Test
	func returnsCharacterFromRepository() async throws {
		// Given
		let expected = Character.stub()
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.result = .success(expected)
		let sut = GetCharacterUseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(identifier: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func callsRepositoryWithCorrectId() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.result = .success(.stub())
		let sut = GetCharacterUseCase(repository: repositoryMock)

		// When
		_ = try await sut.execute(identifier: 42)

		// Then
		#expect(repositoryMock.getCharacterCallCount == 1)
		#expect(repositoryMock.lastRequestedIdentifier == 42)
	}

	@Test
	func propagatesRepositoryError() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.result = .failure(TestError.network)
		let sut = GetCharacterUseCase(repository: repositoryMock)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.execute(identifier: 1)
		}
	}
}

private enum TestError: Error {
	case network
}
