import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct ClearCharactersCacheUseCaseTests {
    // MARK: - Properties

    private let repositoryMock = CharacterRepositoryMock()
    private let sut: ClearCharactersCacheUseCase

    // MARK: - Initialization

    init() {
        sut = ClearCharactersCacheUseCase(repository: repositoryMock)
    }

    // MARK: - Tests

    @Test
    func executeClearsRepositoryPageCache() async {
        // When
        await sut.execute()

        // Then
        #expect(repositoryMock.clearPagesCacheCallCount == 1)
    }
}
