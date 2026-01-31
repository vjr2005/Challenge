import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct RefreshCharacterUseCaseTests {
    // MARK: - Properties

    private let repositoryMock = CharacterRepositoryMock()
    private let sut: RefreshCharacterUseCase

    // MARK: - Initialization

    init() {
        sut = RefreshCharacterUseCase(repository: repositoryMock)
    }

    // MARK: - Tests

    @Test
    func executeRefreshesCharacterFromRepository() async throws {
        // Given
        let expected = Character.stub()
        repositoryMock.refreshResult = .success(expected)

        // When
        let result = try await sut.execute(identifier: 1)

        // Then
        #expect(result == expected)
        #expect(repositoryMock.refreshCharacterCallCount == 1)
    }

    @Test
    func executeCallsRepositoryWithCorrectIdentifier() async throws {
        // Given
        repositoryMock.refreshResult = .success(.stub())

        // When
        _ = try await sut.execute(identifier: 42)

        // Then
        #expect(repositoryMock.lastRefreshedIdentifier == 42)
    }

    @Test
    func executePropagatesRepositoryError() async {
        // Given
        repositoryMock.refreshResult = .failure(.loadFailed)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.execute(identifier: 1)
        }
    }
}
