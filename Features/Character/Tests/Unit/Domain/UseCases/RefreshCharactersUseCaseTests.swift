import ChallengeCore
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct RefreshCharactersUseCaseTests {
    // MARK: - Properties

    private let repositoryMock = CharacterRepositoryMock()
    private let sut: RefreshCharactersUseCase

    // MARK: - Initialization

    init() {
        sut = RefreshCharactersUseCase(repository: repositoryMock)
    }

    // MARK: - Execute

    @Test("Execute returns characters page from repository")
    func executeReturnsCharactersPage() async throws {
        // Given
        let expected = CharactersPage.stub()
        repositoryMock.charactersResult = .success(expected)

        // When
        let value = try await sut.execute(page: 1)

        // Then
        #expect(value == expected)
    }

    @Test("Execute calls repository with correct page and remoteFirst cache policy")
    func executeCallsRepositoryWithCorrectPageAndRemoteFirstCachePolicy() async throws {
        // Given
        repositoryMock.charactersResult = .success(.stub())

        // When
        _ = try await sut.execute(page: 5)

        // Then
        #expect(repositoryMock.getCharactersCallCount == 1)
        #expect(repositoryMock.lastRequestedPage == 5)
        #expect(repositoryMock.lastCharactersCachePolicy == .remoteFirst)
    }

    @Test("Execute propagates repository error")
    func executePropagatesError() async throws {
        // Given
        repositoryMock.charactersResult = .failure(.loadFailed)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.execute(page: 1)
        }
    }
}
