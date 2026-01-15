import Foundation
import Testing

@testable import ChallengeCharacter

struct GetCharacterUseCaseTests {
	@Test
	func returnsCharacterFromRepository() async throws {
		// Given
		let expected = Character.stub()
		let repository = CharacterRepositoryMock()
		repository.result = .success(expected)
		let sut = GetCharacterUseCase(repository: repository)

		// When
		let value = try await sut.execute(id: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func callsRepositoryWithCorrectId() async throws {
		// Given
		let repository = CharacterRepositoryMock()
		repository.result = .success(.stub())
		let sut = GetCharacterUseCase(repository: repository)

		// When
		_ = try await sut.execute(id: 42)

		// Then
		#expect(repository.getCharacterCallCount == 1)
		#expect(repository.lastRequestedId == 42)
	}

	@Test
	func propagatesRepositoryError() async throws {
		// Given
		let repository = CharacterRepositoryMock()
		repository.result = .failure(TestError.network)
		let sut = GetCharacterUseCase(repository: repository)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.execute(id: 1)
		}
	}
}

private enum TestError: Error {
	case network
}
