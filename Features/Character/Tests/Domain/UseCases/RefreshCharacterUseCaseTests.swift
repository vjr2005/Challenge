import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct RefreshCharacterUseCaseTests {
	@Test
	func executeRefreshesCharacterFromRepository() async throws {
		// Given
		let expected = Character.stub()
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.refreshResult = .success(expected)
		let sut = RefreshCharacterUseCase(repository: repositoryMock)

		// When
		let result = try await sut.execute(identifier: 1)

		// Then
		#expect(result == expected)
		#expect(repositoryMock.refreshCharacterCallCount == 1)
	}

	@Test
	func executeCallsRepositoryWithCorrectIdentifier() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.refreshResult = .success(.stub())
		let sut = RefreshCharacterUseCase(repository: repositoryMock)

		// When
		_ = try await sut.execute(identifier: 42)

		// Then
		#expect(repositoryMock.lastRefreshedIdentifier == 42)
	}

	@Test
	func executePropagatesRepositoryError() async {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.refreshResult = .failure(.loadFailed)
		let sut = RefreshCharacterUseCase(repository: repositoryMock)

		// When / Then
		await #expect(throws: CharacterError.loadFailed) {
			_ = try await sut.execute(identifier: 1)
		}
	}
}
