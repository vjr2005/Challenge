import ChallengeCore
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct GetCharactersPageUseCaseTests {
    // MARK: - Properties

    private let repositoryMock = CharactersPageRepositoryMock()
    private let sut: GetCharactersPageUseCase

    // MARK: - Initialization

    init() {
        sut = GetCharactersPageUseCase(repository: repositoryMock)
    }

    // MARK: - Execute

    @Test("Execute returns characters page with correct page and localFirst cache policy")
    func executeReturnsCharactersPage() async throws {
        // Given
        let expected = CharactersPage.stub()
        repositoryMock.charactersResult = .success(expected)

        // When
        let value = try await sut.execute(page: 5)

        // Then
        #expect(value == expected)
        #expect(repositoryMock.getCharactersPageCallCount == 1)
        #expect(repositoryMock.lastRequestedPage == 5)
        #expect(repositoryMock.lastCharactersCachePolicy == .localFirst)
    }

    @Test("Execute propagates repository error")
    func executePropagatesError() async throws {
        // Given
        repositoryMock.charactersResult = .failure(.loadFailed())

        // When / Then
        await #expect(throws: CharactersPageError.loadFailed()) {
            _ = try await sut.execute(page: 1)
        }
    }
}
