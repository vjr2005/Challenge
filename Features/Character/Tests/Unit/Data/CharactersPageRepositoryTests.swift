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
    private let memoryDataSourceMock = CharacterMemoryDataSourceMock()
    private let sut: CharactersPageRepository

    // MARK: - Initialization

    init() {
        sut = CharactersPageRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )
    }

    // MARK: - Get Characters - LocalFirst Policy

    @Test("LocalFirst returns cached page when available")
    func getCharactersPageLocalFirstReturnsCachedPageWhenAvailable() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        let expected = CharactersPage.stub()
        memoryDataSourceMock.pageToReturn = responseDTO

        // When
        let value = try await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    @Test("LocalFirst does not call remote when cache hit")
    func getCharactersPageLocalFirstDoesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        memoryDataSourceMock.pageToReturn = responseDTO

        // When
        _ = try await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 0)
    }

    @Test("LocalFirst fetches from remote when cache miss")
    func getCharactersPageLocalFirstFetchesFromRemoteWhenCacheMiss() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        let expected = CharactersPage.stub()
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        let value = try await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
    }

    @Test("LocalFirst saves page to cache after remote fetch")
    func getCharactersPageLocalFirstSavesPageToCache() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response_two_results")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 1)
        #expect(memoryDataSourceMock.savePageLastResponse == responseDTO)
        #expect(memoryDataSourceMock.savePageLastPage == 1)
    }

    // MARK: - Get Characters - RemoteFirst Policy

    @Test("RemoteFirst always fetches from remote data source")
    func getCharactersPageRemoteFirstAlwaysFetchesFromRemote() async throws {
        // Given
        let cachedResponse: CharactersResponseDTO = try loadJSON("characters_response")
        let freshResponse: CharactersResponseDTO = try loadJSON("characters_response_two_results")
        memoryDataSourceMock.pageToReturn = cachedResponse
        remoteDataSourceMock.charactersResult = .success(freshResponse)

        // When
        let value = try await sut.getCharactersPage(page: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
        #expect(value.characters.count == 2)
    }

    @Test("RemoteFirst saves page to cache after remote fetch")
    func getCharactersPageRemoteFirstSavesPageToCache() async throws {
        // Given
        let freshResponse: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(freshResponse)

        // When
        _ = try await sut.getCharactersPage(page: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 1)
    }

    @Test("RemoteFirst falls back to cache on remote error")
    func getCharactersPageRemoteFirstFallsBackToCacheOnRemoteError() async throws {
        // Given
        let cachedResponse: CharactersResponseDTO = try loadJSON("characters_response")
        memoryDataSourceMock.pageToReturn = cachedResponse
        remoteDataSourceMock.charactersResult = .failure(HTTPError.invalidResponse)

        // When
        let value = try await sut.getCharactersPage(page: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == CharactersPage.stub())
    }

    @Test("RemoteFirst throws error when remote fails and no cache")
    func getCharactersPageRemoteFirstThrowsErrorWhenRemoteFailsAndNoCache() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.invalidResponse)

        // When / Then
        await #expect(throws: CharactersPageError.loadFailed) {
            _ = try await sut.getCharactersPage(page: 1, cachePolicy: .remoteFirst)
        }
    }

    // MARK: - Get Characters - NoCache Policy

    @Test("NoCache policy only fetches from remote")
    func getCharactersPageNoCachePolicyOnlyFetchesFromRemote() async throws {
        // Given
        let remoteResponse: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(remoteResponse)

        // When
        let value = try await sut.getCharactersPage(page: 1, cachePolicy: .noCache)

        // Then
        #expect(value == CharactersPage.stub())
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
    }

    @Test("NoCache policy does not save to cache")
    func getCharactersPageNoCachePolicyDoesNotSaveToCache() async throws {
        // Given
        let remoteResponse: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(remoteResponse)

        // When
        _ = try await sut.getCharactersPage(page: 1, cachePolicy: .noCache)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 0)
    }

    @Test("NoCache policy does not check cache")
    func getCharactersPageNoCachePolicyDoesNotCheckCache() async throws {
        // Given
        let cachedResponse: CharactersResponseDTO = try loadJSON("characters_response")
        let remoteResponse: CharactersResponseDTO = try loadJSON("characters_response_two_results")
        memoryDataSourceMock.pageToReturn = cachedResponse
        remoteDataSourceMock.charactersResult = .success(remoteResponse)

        // When
        let value = try await sut.getCharactersPage(page: 1, cachePolicy: .noCache)

        // Then
        #expect(value.characters.count == 2)
        #expect(memoryDataSourceMock.getPageCallCount == 0)
    }

    // MARK: - Get Characters - Pagination

    @Test("Get characters calls remote with correct page number")
    func getCharactersPageCallsRemoteWithCorrectPage() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.getCharactersPage(page: 5, cachePolicy: .localFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
        #expect(remoteDataSourceMock.lastFetchedPage == 5)
    }

    // MARK: - Get Characters - Errors

    @Test("Get characters maps HTTP 404 to invalid page error")
    func getCharactersPageMapsHTTPNotFoundToInvalidPage() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: CharactersPageError.invalidPage(page: 5)) {
            _ = try await sut.getCharactersPage(page: 5, cachePolicy: .localFirst)
        }
    }

    @Test("Get characters maps HTTP 500 to load failed error")
    func getCharactersPageMapsHTTPServerErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(500, Data()))

        // When / Then
        await #expect(throws: CharactersPageError.loadFailed) {
            _ = try await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)
        }
    }

    @Test("Get characters does not save to cache on error")
    func getCharactersPageDoesNotSaveToCacheOnError() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.invalidResponse)

        // When
        _ = try? await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 0)
    }

    @Test("Get characters maps generic error to load failed error")
    func getCharactersPageMapsGenericErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(GenericTestError.unknown)

        // When / Then
        await #expect(throws: CharactersPageError.loadFailed) {
            _ = try await sut.getCharactersPage(page: 1, cachePolicy: .localFirst)
        }
    }

    // MARK: - Search Characters

    @Test("Search characters always calls remote data source")
    func searchCharactersPageAlwaysCallsRemote() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)
        memoryDataSourceMock.pageToReturn = responseDTO

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
        #expect(memoryDataSourceMock.savePageCallCount == 0)
    }

    @Test("Search characters passes query to remote data source")
    func searchCharactersPagePassesQueryToRemoteDataSource() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharactersPage(page: 1, filter: CharacterFilter(name: "Morty"))

        // Then
        #expect(remoteDataSourceMock.lastFetchedFilter == CharacterFilter(name: "Morty"))
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
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(404, Data()))

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
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(500, Data()))

        // When / Then
        await #expect(throws: CharactersPageError.loadFailed) {
            _ = try await sut.searchCharactersPage(page: 1, filter: CharacterFilter(name: "Rick"))
        }
    }

    @Test("Search characters maps generic error to load failed error")
    func searchCharactersPageMapsGenericErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(GenericTestError.unknown)

        // When / Then
        await #expect(throws: CharactersPageError.loadFailed) {
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

private enum GenericTestError: Error {
    case unknown
}
