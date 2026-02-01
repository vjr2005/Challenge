import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct GetCharactersUseCaseTests {
    // MARK: - Properties

    private let repositoryMock = CharacterRepositoryMock()
    private let sut: GetCharactersUseCase

    // MARK: - Initialization

    init() {
        sut = GetCharactersUseCase(repository: repositoryMock)
    }

    // MARK: - Execute with CachePolicy

    @Test("Execute returns characters page from repository")
    func executeReturnsCharactersPage() async throws {
        // Given
        let expected = CharactersPage.stub()
        repositoryMock.charactersResult = .success(expected)

        // When
        let value = try await sut.execute(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    @Test("Execute calls repository with correct page and cache policy")
    func executeCallsRepositoryWithCorrectPageAndCachePolicy() async throws {
        // Given
        repositoryMock.charactersResult = .success(.stub())

        // When
        _ = try await sut.execute(page: 5, cachePolicy: .remoteFirst)

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
            _ = try await sut.execute(page: 1, cachePolicy: .localFirst)
        }
    }

    // MARK: - Default Extension

    @Test("Default execute uses localFirst cache policy")
    func defaultExecuteUsesLocalFirstCachePolicy() async throws {
        // Given
        repositoryMock.charactersResult = .success(.stub())

        // When
        _ = try await sut.execute(page: 1)

        // Then
        #expect(repositoryMock.lastCharactersCachePolicy == .localFirst)
    }
}
