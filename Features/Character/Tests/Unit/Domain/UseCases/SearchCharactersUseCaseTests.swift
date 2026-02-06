import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct SearchCharactersUseCaseTests {
    // MARK: - Properties

    private let repositoryMock = CharacterRepositoryMock()
    private let sut: SearchCharactersUseCase

    // MARK: - Initialization

    init() {
        sut = SearchCharactersUseCase(repository: repositoryMock)
    }

    // MARK: - Tests

    @Test("Execute returns characters page from repository search")
    func executeReturnsCharactersPage() async throws {
        // Given
        let expected = CharactersPage.stub()
        repositoryMock.searchResult = .success(expected)

        // When
        let value = try await sut.execute(page: 1, filter: CharacterFilter(name: "Rick"))

        // Then
        #expect(value == expected)
    }

    @Test("Execute calls repository with correct page and filter")
    func executeCallsRepositoryWithCorrectPageAndFilter() async throws {
        // Given
        repositoryMock.searchResult = .success(.stub())
        let filter = CharacterFilter(name: "Morty", status: .alive)

        // When
        _ = try await sut.execute(page: 3, filter: filter)

        // Then
        #expect(repositoryMock.searchCharactersCallCount == 1)
        #expect(repositoryMock.lastSearchedPage == 3)
        #expect(repositoryMock.lastSearchedFilter == filter)
    }

    @Test("Execute propagates repository error")
    func executePropagatesError() async throws {
        // Given
        repositoryMock.searchResult = .failure(.loadFailed)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.execute(page: 1, filter: CharacterFilter(name: "Rick"))
        }
    }
}
