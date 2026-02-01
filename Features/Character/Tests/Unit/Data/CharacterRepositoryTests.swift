import ChallengeCoreMocks
import ChallengeNetworking
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterRepositoryTests {
    // MARK: - Properties

    private let remoteDataSourceMock = CharacterRemoteDataSourceMock()
    private let memoryDataSourceMock = CharacterMemoryDataSourceMock()
    private let sut: CharacterRepository

    // MARK: - Initialization

    init() {
        sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )
    }

    // MARK: - Get Character - LocalFirst Policy (Default)

    @Test("LocalFirst returns cached character when available in memory")
    func localFirstReturnsCachedCharacterWhenAvailable() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        let expected = Character.stub()
        memoryDataSourceMock.characterToReturn = characterDTO

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    @Test("LocalFirst does not call remote data source when cache hit")
    func localFirstDoesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        memoryDataSourceMock.characterToReturn = characterDTO

        // When
        _ = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 0)
    }

    @Test("LocalFirst fetches from remote data source when cache miss")
    func localFirstFetchesFromRemoteWhenCacheMiss() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        let expected = Character.stub()
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
    }

    @Test("LocalFirst saves character to cache after remote fetch")
    func localFirstSavesToCacheAfterRemoteFetch() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        _ = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(memoryDataSourceMock.saveCharacterCallCount == 1)
        #expect(memoryDataSourceMock.saveCharacterLastValue == characterDTO)
    }

    // MARK: - Get Character - RemoteFirst Policy

    @Test("RemoteFirst always fetches from remote data source")
    func remoteFirstAlwaysFetchesFromRemote() async throws {
        // Given
        let cachedDTO: CharacterDTO = try loadJSON("character")
        let freshDTO: CharacterDTO = try loadJSON("character_dead")
        remoteDataSourceMock.result = .success(freshDTO)
        memoryDataSourceMock.characterToReturn = cachedDTO

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
        #expect(value.status == .dead)
    }

    @Test("RemoteFirst saves character to cache after remote fetch")
    func remoteFirstSavesToCacheAfterRemoteFetch() async throws {
        // Given
        let freshDTO: CharacterDTO = try loadJSON("character_dead")
        remoteDataSourceMock.result = .success(freshDTO)

        // When
        _ = try await sut.getCharacter(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(memoryDataSourceMock.saveCharacterCallCount == 1)
        #expect(memoryDataSourceMock.saveCharacterLastValue == freshDTO)
    }

    @Test("RemoteFirst falls back to cache on remote error")
    func remoteFirstFallsBackToCacheOnRemoteError() async throws {
        // Given
        let cachedDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)
        memoryDataSourceMock.characterToReturn = cachedDTO

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == Character.stub())
    }

    @Test("RemoteFirst throws error when remote fails and no cache")
    func remoteFirstThrowsErrorWhenRemoteFailsAndNoCache() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacter(identifier: 1, cachePolicy: .remoteFirst)
        }
    }

    // MARK: - Get Character - None Policy

    @Test("None policy only fetches from remote")
    func nonePolicyOnlyFetchesFromRemote() async throws {
        // Given
        let remoteDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(remoteDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .none)

        // Then
        #expect(value == Character.stub())
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
    }

    @Test("None policy does not save to cache")
    func nonePolicyDoesNotSaveToCache() async throws {
        // Given
        let remoteDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(remoteDTO)

        // When
        _ = try await sut.getCharacter(identifier: 1, cachePolicy: .none)

        // Then
        #expect(memoryDataSourceMock.saveCharacterCallCount == 0)
    }

    @Test("None policy does not check cache")
    func nonePolicyDoesNotCheckCache() async throws {
        // Given
        let cachedDTO: CharacterDTO = try loadJSON("character")
        let remoteDTO: CharacterDTO = try loadJSON("character_dead")
        memoryDataSourceMock.characterToReturn = cachedDTO
        remoteDataSourceMock.result = .success(remoteDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .none)

        // Then
        #expect(value.status == .dead)
        #expect(memoryDataSourceMock.getCharacterCallCount == 0)
    }

    // MARK: - Transformation Tests

    @Test("Transforms dead status from DTO to domain model")
    func transformsDeadStatus() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_dead")
        let expected = Character.stub(status: .dead)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    @Test("Transforms unknown status from DTO to domain model")
    func transformsUnknownStatus() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_unknown_status")
        let expected = Character.stub(status: .unknown)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    // MARK: - Gender Transformation Tests

    @Test("Transforms female gender from DTO to domain model")
    func transformsFemaleGender() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_female")
        let expected = Character.stub(gender: .female)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    @Test("Transforms genderless gender from DTO to domain model")
    func transformsGenderlessGender() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_genderless")
        let expected = Character.stub(gender: .genderless)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    @Test("Transforms unknown gender from DTO to domain model")
    func transformsUnknownGender() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_unknown_gender")
        let expected = Character.stub(gender: .unknown)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    // MARK: - Error Mapping Tests

    @Test("Maps HTTP 404 error to character not found error")
    func mapsHTTPNotFoundErrorToCharacterNotFound() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: CharacterError.characterNotFound(id: 42)) {
            _ = try await sut.getCharacter(identifier: 42, cachePolicy: .localFirst)
        }
    }

    @Test("Maps HTTP 500 server error to load failed error")
    func mapsHTTPServerErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.statusCode(500, Data()))

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)
        }
    }

    @Test("Maps HTTP invalid URL error to load failed error")
    func mapsHTTPInvalidURLToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidURL)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)
        }
    }

    @Test("Maps HTTP invalid response error to load failed error")
    func mapsHTTPInvalidResponseToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)
        }
    }

    @Test("Maps generic error to load failed error")
    func mapsGenericErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.result = .failure(GenericTestError.unknown)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)
        }
    }

    @Test("Does not save to cache when remote fetch fails")
    func doesNotSaveToCacheOnRemoteError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When
        _ = try? await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(memoryDataSourceMock.saveCharacterCallCount == 0)
    }

    // MARK: - Get Characters (Paginated) - LocalFirst Policy

    @Test("LocalFirst returns cached page when available")
    func getCharactersLocalFirstReturnsCachedPageWhenAvailable() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        let expected = CharactersPage.stub()
        memoryDataSourceMock.pageToReturn = responseDTO

        // When
        let value = try await sut.getCharacters(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    @Test("LocalFirst does not call remote when cache hit")
    func getCharactersLocalFirstDoesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        memoryDataSourceMock.pageToReturn = responseDTO

        // When
        _ = try await sut.getCharacters(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 0)
    }

    @Test("LocalFirst fetches from remote when cache miss")
    func getCharactersLocalFirstFetchesFromRemoteWhenCacheMiss() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        let expected = CharactersPage.stub()
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        let value = try await sut.getCharacters(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
    }

    @Test("LocalFirst saves page to cache after remote fetch")
    func getCharactersLocalFirstSavesPageToCache() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response_two_results")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.getCharacters(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 1)
        #expect(memoryDataSourceMock.savePageLastResponse == responseDTO)
        #expect(memoryDataSourceMock.savePageLastPage == 1)
    }

    // MARK: - Get Characters (Paginated) - RemoteFirst Policy

    @Test("RemoteFirst always fetches from remote data source")
    func getCharactersRemoteFirstAlwaysFetchesFromRemote() async throws {
        // Given
        let cachedResponse: CharactersResponseDTO = try loadJSON("characters_response")
        let freshResponse: CharactersResponseDTO = try loadJSON("characters_response_two_results")
        memoryDataSourceMock.pageToReturn = cachedResponse
        remoteDataSourceMock.charactersResult = .success(freshResponse)

        // When
        let value = try await sut.getCharacters(page: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
        #expect(value.characters.count == 2)
    }

    @Test("RemoteFirst saves page to cache after remote fetch")
    func getCharactersRemoteFirstSavesPageToCache() async throws {
        // Given
        let freshResponse: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(freshResponse)

        // When
        _ = try await sut.getCharacters(page: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 1)
    }

    @Test("RemoteFirst falls back to cache on remote error")
    func getCharactersRemoteFirstFallsBackToCacheOnRemoteError() async throws {
        // Given
        let cachedResponse: CharactersResponseDTO = try loadJSON("characters_response")
        memoryDataSourceMock.pageToReturn = cachedResponse
        remoteDataSourceMock.charactersResult = .failure(HTTPError.invalidResponse)

        // When
        let value = try await sut.getCharacters(page: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == CharactersPage.stub())
    }

    @Test("RemoteFirst throws error when remote fails and no cache")
    func getCharactersRemoteFirstThrowsErrorWhenRemoteFailsAndNoCache() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.invalidResponse)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacters(page: 1, cachePolicy: .remoteFirst)
        }
    }

    // MARK: - Get Characters (Paginated) - None Policy

    @Test("None policy only fetches from remote")
    func getCharactersNonePolicyOnlyFetchesFromRemote() async throws {
        // Given
        let remoteResponse: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(remoteResponse)

        // When
        let value = try await sut.getCharacters(page: 1, cachePolicy: .none)

        // Then
        #expect(value == CharactersPage.stub())
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
    }

    @Test("None policy does not save to cache")
    func getCharactersNonePolicyDoesNotSaveToCache() async throws {
        // Given
        let remoteResponse: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(remoteResponse)

        // When
        _ = try await sut.getCharacters(page: 1, cachePolicy: .none)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 0)
    }

    @Test("None policy does not check cache")
    func getCharactersNonePolicyDoesNotCheckCache() async throws {
        // Given
        let cachedResponse: CharactersResponseDTO = try loadJSON("characters_response")
        let remoteResponse: CharactersResponseDTO = try loadJSON("characters_response_two_results")
        memoryDataSourceMock.pageToReturn = cachedResponse
        remoteDataSourceMock.charactersResult = .success(remoteResponse)

        // When
        let value = try await sut.getCharacters(page: 1, cachePolicy: .none)

        // Then
        #expect(value.characters.count == 2)
        #expect(memoryDataSourceMock.getPageCallCount == 0)
    }

    // MARK: - Get Characters (Paginated) - Pagination

    @Test("Get characters calls remote with correct page number")
    func getCharactersCallsRemoteWithCorrectPage() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.getCharacters(page: 5, cachePolicy: .localFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
        #expect(remoteDataSourceMock.lastFetchedPage == 5)
    }

    @Test("Get characters transforms pagination info correctly")
    func getCharactersTransformsPaginationInfo() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response_pagination")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        let value = try await sut.getCharacters(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(value.totalCount == 100)
        #expect(value.totalPages == 5)
        #expect(value.hasNextPage == true)
        #expect(value.hasPreviousPage == false)
    }

    // MARK: - Get Characters (Paginated) - Errors

    @Test("Get characters maps HTTP 404 to invalid page error")
    func getCharactersMapsHTTPNotFoundToInvalidPage() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: CharacterError.invalidPage(page: 5)) {
            _ = try await sut.getCharacters(page: 5, cachePolicy: .localFirst)
        }
    }

    @Test("Get characters maps HTTP 500 to load failed error")
    func getCharactersMapsHTTPServerErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(500, Data()))

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacters(page: 1, cachePolicy: .localFirst)
        }
    }

    @Test("Get characters does not save to cache on error")
    func getCharactersDoesNotSaveToCacheOnError() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.invalidResponse)

        // When
        _ = try? await sut.getCharacters(page: 1, cachePolicy: .localFirst)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 0)
    }

    @Test("Get characters maps generic error to load failed error")
    func getCharactersMapsGenericErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(GenericTestError.unknown)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacters(page: 1, cachePolicy: .localFirst)
        }
    }

    // MARK: - Search Characters (Always Remote, No Cache)

    @Test("Search characters always calls remote data source")
    func searchCharactersAlwaysCallsRemote() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)
        memoryDataSourceMock.pageToReturn = responseDTO

        // When
        _ = try await sut.searchCharacters(page: 1, query: "Rick")

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
    }

    @Test("Search characters does not save results to cache")
    func searchCharactersDoesNotSaveToCache() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharacters(page: 1, query: "Rick")

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 0)
    }

    @Test("Search characters passes query to remote data source")
    func searchCharactersPassesQueryToRemoteDataSource() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharacters(page: 1, query: "Morty")

        // Then
        #expect(remoteDataSourceMock.lastFetchedQuery == "Morty")
    }

    @Test("Search characters passes page number to remote data source")
    func searchCharactersPassesPageToRemoteDataSource() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharacters(page: 3, query: "Rick")

        // Then
        #expect(remoteDataSourceMock.lastFetchedPage == 3)
    }

    @Test("Search characters maps HTTP 404 to invalid page error")
    func searchCharactersMapsHTTPNotFoundToInvalidPage() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: CharacterError.invalidPage(page: 5)) {
            _ = try await sut.searchCharacters(page: 5, query: "Rick")
        }
    }

    @Test("Search characters maps generic error to load failed error")
    func searchCharactersMapsGenericErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(GenericTestError.unknown)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.searchCharacters(page: 1, query: "Rick")
        }
    }

}

// MARK: - Private

private extension CharacterRepositoryTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }
}

private enum GenericTestError: Error {
    case unknown
}
