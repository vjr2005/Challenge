import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct ClearCharactersCacheUseCaseTests {
	@Test
	func executeClearsRepositoryPageCache() async {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		let sut = ClearCharactersCacheUseCase(repository: repositoryMock)

		// When
		await sut.execute()

		// Then
		#expect(repositoryMock.clearPagesCacheCallCount == 1)
	}
}
