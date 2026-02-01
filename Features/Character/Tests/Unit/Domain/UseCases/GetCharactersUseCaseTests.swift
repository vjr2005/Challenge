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

    @Test("Execute without query returns characters page")
    func executeWithoutQueryReturnsCharactersPage() async throws {
        // Given
        let expected = CharactersPage.stub()
        repositoryMock.charactersResult = .success(expected)

        // When
        let value = try await sut.execute(page: 1, query: nil)

        // Then
        #expect(value == expected)
    }

    @Test("Execute without query calls getCharacters method")
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

    @Test("Execute with empty query calls getCharacters method")
    func executeWithEmptyQueryCallsGetCharacters() async throws {
        // Given
        repositoryMock.charactersResult = .success(.stub())

        // When
        _ = try await sut.execute(page: 1, query: "")

        // Then
        #expect(repositoryMock.getCharactersCallCount == 1)
        #expect(repositoryMock.searchCharactersCallCount == 0)
    }

    @Test("Execute without query propagates error")
    func executeWithoutQueryPropagatesError() async throws {
        // Given
        repositoryMock.charactersResult = .failure(.loadFailed)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.execute(page: 1, query: nil)
        }
    }

    // MARK: - With Query (uses searchCharacters)

    @Test("Execute with query returns characters page")
    func executeWithQueryReturnsCharactersPage() async throws {
        // Given
        let expected = CharactersPage.stub()
        repositoryMock.searchResult = .success(expected)

        // When
        let value = try await sut.execute(page: 1, query: "Rick")

        // Then
        #expect(value == expected)
    }

    @Test("Execute with query calls searchCharacters method")
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

    @Test("Execute with query propagates error")
    func executeWithQueryPropagatesError() async throws {
        // Given
        repositoryMock.searchResult = .failure(.loadFailed)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.execute(page: 1, query: "Rick")
        }
    }
}
