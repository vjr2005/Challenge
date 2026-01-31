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

    // MARK: - Without Query (uses getCharacters)

    @Test
    func executeWithoutQueryReturnsCharactersPage() async throws {
        // Given
        let expected = CharactersPage.stub()
        repositoryMock.charactersResult = .success(expected)

        // When
        let value = try await sut.execute(page: 1, query: nil)

        // Then
        #expect(value == expected)
    }

    @Test
    func executeWithoutQueryCallsGetCharacters() async throws {
        // Given
        repositoryMock.charactersResult = .success(.stub())

        // When
        _ = try await sut.execute(page: 5, query: nil)

        // Then
        #expect(repositoryMock.getCharactersCallCount == 1)
        #expect(repositoryMock.lastRequestedPage == 5)
        #expect(repositoryMock.searchCharactersCallCount == 0)
    }

    @Test
    func executeWithEmptyQueryCallsGetCharacters() async throws {
        // Given
        repositoryMock.charactersResult = .success(.stub())

        // When
        _ = try await sut.execute(page: 1, query: "")

        // Then
        #expect(repositoryMock.getCharactersCallCount == 1)
        #expect(repositoryMock.searchCharactersCallCount == 0)
    }

    @Test
    func executeWithoutQueryPropagatesError() async throws {
        // Given
        repositoryMock.charactersResult = .failure(.loadFailed)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.execute(page: 1, query: nil)
        }
    }

    // MARK: - With Query (uses searchCharacters)

    @Test
    func executeWithQueryReturnsCharactersPage() async throws {
        // Given
        let expected = CharactersPage.stub()
        repositoryMock.searchResult = .success(expected)

        // When
        let value = try await sut.execute(page: 1, query: "Rick")

        // Then
        #expect(value == expected)
    }

    @Test
    func executeWithQueryCallsSearchCharacters() async throws {
        // Given
        repositoryMock.searchResult = .success(.stub())

        // When
        _ = try await sut.execute(page: 3, query: "Morty")

        // Then
        #expect(repositoryMock.searchCharactersCallCount == 1)
        #expect(repositoryMock.lastSearchedPage == 3)
        #expect(repositoryMock.lastSearchedQuery == "Morty")
        #expect(repositoryMock.getCharactersCallCount == 0)
    }

    @Test
    func executeWithQueryPropagatesError() async throws {
        // Given
        repositoryMock.searchResult = .failure(.loadFailed)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.execute(page: 1, query: "Rick")
        }
    }
}
