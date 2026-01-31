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

    // MARK: - Cache Hit Tests

    @Test
    func returnsCachedCharacterWhenAvailable() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        let expected = Character.stub()
        memoryDataSourceMock.characterToReturn = characterDTO

        // When
        let value = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func doesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        memoryDataSourceMock.characterToReturn = characterDTO

        // When
        _ = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 0)
    }

    // MARK: - Cache Miss Tests

    @Test
    func fetchesFromRemoteWhenCacheMiss() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        let expected = Character.stub()
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
    }

    @Test
    func savesToCacheAfterRemoteFetch() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        _ = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(memoryDataSourceMock.saveCharacterCallCount == 1)
        #expect(memoryDataSourceMock.saveCharacterLastValue == characterDTO)
    }

    @Test
    func callsRemoteDataSourceWithCorrectId() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        _ = try await sut.getCharacter(identifier: 42)

        // Then
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
        #expect(remoteDataSourceMock.lastFetchedIdentifier == 42)
    }

    // MARK: - Transformation Tests

    @Test
    func transformsDeadStatus() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_dead")
        let expected = Character.stub(status: .dead)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func transformsUnknownStatus() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_unknown_status")
        let expected = Character.stub(status: .unknown)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == expected)
    }

    // MARK: - Gender Transformation Tests

    @Test
    func transformsFemaleGender() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_female")
        let expected = Character.stub(gender: .female)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func transformsGenderlessGender() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_genderless")
        let expected = Character.stub(gender: .genderless)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func transformsUnknownGender() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character_unknown_gender")
        let expected = Character.stub(gender: .unknown)
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == expected)
    }

    // MARK: - Error Mapping Tests

    @Test
    func mapsHTTPNotFoundErrorToCharacterNotFound() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: CharacterError.characterNotFound(id: 42)) {
            _ = try await sut.getCharacter(identifier: 42)
        }
    }

    @Test
    func mapsHTTPServerErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.statusCode(500, Data()))

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacter(identifier: 1)
        }
    }

    @Test
    func mapsHTTPInvalidURLToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidURL)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacter(identifier: 1)
        }
    }

    @Test
    func mapsHTTPInvalidResponseToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacter(identifier: 1)
        }
    }

    @Test
    func mapsGenericErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.result = .failure(GenericTestError.unknown)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacter(identifier: 1)
        }
    }

    @Test
    func doesNotSaveToCacheOnRemoteError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When
        _ = try? await sut.getCharacter(identifier: 1)

        // Then
        #expect(memoryDataSourceMock.saveCharacterCallCount == 0)
    }

    // MARK: - Get Characters (Paginated) - Cache Hit

    @Test
    func getCharactersReturnsCachedPageWhenAvailable() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        let expected = CharactersPage.stub()
        memoryDataSourceMock.pageToReturn = responseDTO

        // When
        let value = try await sut.getCharacters(page: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func getCharactersDoesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        memoryDataSourceMock.pageToReturn = responseDTO

        // When
        _ = try await sut.getCharacters(page: 1)

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 0)
    }

    // MARK: - Get Characters (Paginated) - Cache Miss

    @Test
    func getCharactersFetchesFromRemoteWhenCacheMiss() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        let expected = CharactersPage.stub()
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        let value = try await sut.getCharacters(page: 1)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
    }

    @Test
    func getCharactersCallsRemoteWithCorrectPage() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.getCharacters(page: 5)

        // Then
        #expect(remoteDataSourceMock.fetchCharactersCallCount == 1)
        #expect(remoteDataSourceMock.lastFetchedPage == 5)
    }

    @Test
    func getCharactersSavesPageToCache() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response_two_results")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.getCharacters(page: 1)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 1)
        #expect(memoryDataSourceMock.savePageLastResponse == responseDTO)
        #expect(memoryDataSourceMock.savePageLastPage == 1)
    }

    @Test
    func getCharactersTransformsPaginationInfo() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response_pagination")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        let value = try await sut.getCharacters(page: 1)

        // Then
        #expect(value.totalCount == 100)
        #expect(value.totalPages == 5)
        #expect(value.hasNextPage == true)
        #expect(value.hasPreviousPage == false)
    }

    // MARK: - Get Characters (Paginated) - Errors

    @Test
    func getCharactersMapsHTTPNotFoundToInvalidPage() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: CharacterError.invalidPage(page: 5)) {
            _ = try await sut.getCharacters(page: 5)
        }
    }

    @Test
    func getCharactersMapsHTTPServerErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(500, Data()))

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacters(page: 1)
        }
    }

    @Test
    func getCharactersDoesNotSaveToCacheOnError() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.invalidResponse)

        // When
        _ = try? await sut.getCharacters(page: 1)

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 0)
    }

    @Test
    func getCharactersMapsGenericErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(GenericTestError.unknown)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.getCharacters(page: 1)
        }
    }

    // MARK: - Search Characters (Always Remote, No Cache)

    @Test
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

    @Test
    func searchCharactersDoesNotSaveToCache() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharacters(page: 1, query: "Rick")

        // Then
        #expect(memoryDataSourceMock.savePageCallCount == 0)
    }

    @Test
    func searchCharactersPassesQueryToRemoteDataSource() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharacters(page: 1, query: "Morty")

        // Then
        #expect(remoteDataSourceMock.lastFetchedQuery == "Morty")
    }

    @Test
    func searchCharactersPassesPageToRemoteDataSource() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        remoteDataSourceMock.charactersResult = .success(responseDTO)

        // When
        _ = try await sut.searchCharacters(page: 3, query: "Rick")

        // Then
        #expect(remoteDataSourceMock.lastFetchedPage == 3)
    }

    @Test
    func searchCharactersMapsHTTPNotFoundToInvalidPage() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: CharacterError.invalidPage(page: 5)) {
            _ = try await sut.searchCharacters(page: 5, query: "Rick")
        }
    }

    @Test
    func searchCharactersMapsGenericErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.charactersResult = .failure(GenericTestError.unknown)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.searchCharacters(page: 1, query: "Rick")
        }
    }

    // MARK: - Refresh Character

    @Test
    func refreshCharacterAlwaysFetchesFromRemote() async throws {
        // Given
        let cachedDTO: CharacterDTO = try loadJSON("character")
        let freshDTO: CharacterDTO = try loadJSON("character_dead")
        remoteDataSourceMock.result = .success(freshDTO)
        memoryDataSourceMock.characterToReturn = cachedDTO

        // When
        let value = try await sut.refreshCharacter(identifier: 1)

        // Then
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
        #expect(value.status == .dead)
    }

    @Test
    func refreshCharacterUpdatesCharacterInPages() async throws {
        // Given
        let freshDTO: CharacterDTO = try loadJSON("character_dead")
        remoteDataSourceMock.result = .success(freshDTO)

        // When
        _ = try await sut.refreshCharacter(identifier: 1)

        // Then
        #expect(memoryDataSourceMock.updateCharacterInPagesCallCount == 1)
        #expect(memoryDataSourceMock.lastUpdatedCharacter == freshDTO)
    }

    @Test
    func refreshCharacterCallsRemoteWithCorrectIdentifier() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        _ = try await sut.refreshCharacter(identifier: 42)

        // Then
        #expect(remoteDataSourceMock.lastFetchedIdentifier == 42)
    }

    @Test
    func refreshCharacterMapsHTTPNotFoundToCharacterNotFound() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: CharacterError.characterNotFound(id: 42)) {
            _ = try await sut.refreshCharacter(identifier: 42)
        }
    }

    @Test
    func refreshCharacterMapsGenericErrorToLoadFailed() async throws {
        // Given
        remoteDataSourceMock.result = .failure(GenericTestError.unknown)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.refreshCharacter(identifier: 1)
        }
    }

    @Test
    func refreshCharacterDoesNotUpdateCacheOnError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When
        _ = try? await sut.refreshCharacter(identifier: 1)

        // Then
        #expect(memoryDataSourceMock.updateCharacterInPagesCallCount == 0)
    }

    // MARK: - Clear Pages Cache

    @Test
    func clearPagesCacheClearsMemoryDataSource() async {
        // When
        await sut.clearPagesCache()

        // Then
        #expect(memoryDataSourceMock.clearPagesCallCount == 1)
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
