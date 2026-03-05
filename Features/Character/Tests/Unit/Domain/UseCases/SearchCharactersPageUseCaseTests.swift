import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct SearchCharactersPageUseCaseTests {
    // MARK: - Properties

    private let repositoryMock = CharactersPageRepositoryMock()
    private let sut: SearchCharactersPageUseCase

    // MARK: - Initialization

    init() {
        sut = SearchCharactersPageUseCase(repository: repositoryMock)
    }

    // MARK: - Tests

    @Test("Execute returns characters page with correct page and filter")
    func executeReturnsCharactersPage() async throws {
        // Given
        let expected = CharactersPage.stub()
        let filter = CharacterFilter(name: "Morty", status: .alive)
        repositoryMock.searchResult = .success(expected)

        // When
        let value = try await sut.execute(page: 3, filter: filter)

        // Then
        #expect(value == expected)
        #expect(repositoryMock.searchCharactersPageCallCount == 1)
        #expect(repositoryMock.lastSearchedPage == 3)
        #expect(repositoryMock.lastSearchedFilter == filter)
    }

    @Test("Execute propagates repository error")
    func executePropagatesError() async throws {
        // Given
        repositoryMock.searchResult = .failure(.loadFailed())

        // When / Then
        await #expect(throws: CharactersPageError.loadFailed()) {
            _ = try await sut.execute(page: 1, filter: CharacterFilter(name: "Rick"))
        }
    }
}
