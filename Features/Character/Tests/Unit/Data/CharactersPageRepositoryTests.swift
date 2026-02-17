import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworking
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharactersPageRepositoryTests {
    // MARK: - Properties

    private let remoteDataSourceMock = CharacterRemoteDataSourceMock()
    private let volatileDataSourceMock = CharacterLocalDataSourceMock()
    private let persistenceDataSourceMock = CharacterLocalDataSourceMock()
    private let sut: CharactersPageRepository

    // MARK: - Initialization

    init() {
        sut = CharactersPageRepository(
            remoteDataSource: remoteDataSourceMock,
            volatile: volatileDataSourceMock,
            persistence: persistenceDataSourceMock
        )
    }

    // MARK: - Get Characters - Remote Fetch

    @Test("Fetches from remote and maps to domain model")
    func fetchesFromRemoteAndMapsToDomainModel() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        let expected = CharactersPage.stub()
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        let value = try await sut.getCharactersPage(page: 1, cachePolicy: .noCache)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
    }

    @Test("Passes correct page number to remote data source")
    func passesCorrectPageToRemote() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.getCharactersPage(page: 5, cachePolicy: .noCache)

        // Then
        #expect(remoteDataSourceMock.lastFetchedPage == 5)
    }

    // MARK: - Get Characters - Cache Wiring

    @Test("Returns volatile cached page without calling remote")
    func returnsVolatileCachedPage() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        await volatileDataSourceMock.setPageToReturn(responseDTO)

        // When
        let value = try await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == CharactersPage.stub())
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 0)
    }

    @Test("Falls back to persistence when volatile misses")
    func fallsBackToPersistenceWhenVolatileMisses() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        await persistenceDataSourceMock.setPageToReturn(responseDTO)

        // When
        let value = try await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == CharactersPage.stub())
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 0)
        #expect(await volatileDataSourceMock.savePageCallCount == 1)
    }

    @Test("Saves page to cache after successful remote fetch")
    func savesPageToCacheAfterRemoteFetch() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(await volatileDataSourceMock.savePageCallCount == 1)
        #expect(await volatileDataSourceMock.savePageLastResponse == responseDTO)
        #expect(await volatileDataSourceMock.savePageLastPage == 1)
        #expect(await persistenceDataSourceMock.savePageCallCount == 1)
        #expect(await persistenceDataSourceMock.savePageLastResponse == responseDTO)
        #expect(await persistenceDataSourceMock.savePageLastPage == 1)
    }

    // MARK: - Get Characters - Error Handling

    @Test("Does not save to cache on error")
    func doesNotSaveToCacheOnError() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(APIError.invalidResponse)

        // When
        _ = try? await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(await volatileDataSourceMock.savePageCallCount == 0)
        #expect(await persistenceDataSourceMock.savePageCallCount == 0)
    }

    // MARK: - Search Characters

    @Test("Search characters always calls remote data source")
    func searchCharactersPageAlwaysCallsRemote() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)
        await volatileDataSourceMock.setPageToReturn(responseDTO)

        // When
        _ = try await sut.searchCharactersPage(page: 1, filter: CharacterFilter(name: "Rick"))

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
    }

    @Test("Search characters does not save results to cache")
    func searchCharactersPageDoesNotSaveToCache() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharactersPage(page: 1, filter: CharacterFilter(name: "Rick"))

        // Then
        #expect(await volatileDataSourceMock.savePageCallCount == 0)
        #expect(await persistenceDataSourceMock.savePageCallCount == 0)
    }

    @Test("Search characters passes query to remote data source")
    func searchCharactersPagePassesQueryToRemoteDataSource() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharactersPage(page: 1, filter: CharacterFilter(name: "Morty"))

        // Then
        #expect(remoteDataSourceMock.lastFetchedFilter == CharacterFilterDTO(name: "Morty"))
    }

    @Test("Search characters passes page number to remote data source")
    func searchCharactersPagePassesPageToRemoteDataSource() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharactersPage(page: 3, filter: CharacterFilter(name: "Rick"))

        // Then
        #expect(remoteDataSourceMock.lastFetchedPage == 3)
    }

    @Test("Search characters returns empty page when HTTP 404")
    func searchCharactersPageReturnsEmptyPageWhenNotFound() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(APIError.notFound)

        // When
        let result = try await sut.searchCharactersPage(page: 1, filter: CharacterFilter(name: "NonExistentCharacter"))

        // Then
        let expected = CharactersPage(
            characters: [],
            currentPage: 1,
            totalPages: 0,
            totalCount: 0,
            hasNextPage: false,
            hasPreviousPage: false
        )
        #expect(result == expected)
    }

    @Test("Search characters maps HTTP 500 to load failed error")
    func searchCharactersPageMapsHTTPServerErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(APIError.serverError(statusCode: 500))

        // When / Then
        await #expect(throws: CharactersPageError.loadFailed()) {
            _ = try await sut.searchCharactersPage(page: 1, filter: CharacterFilter(name: "Rick"))
        }
    }
}

// MARK: - Private

private extension CharactersPageRepositoryTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }
}
