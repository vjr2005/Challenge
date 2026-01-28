import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterRepositoryTests {
    // MARK: - Cache Hit Tests

    @Test
    func returnsCachedCharacterWhenAvailable() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        let expected = Character.stub()
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        memoryDataSourceMock.characterToReturn = characterDTO
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func doesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        memoryDataSourceMock.characterToReturn = characterDTO
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .success(characterDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .success(characterDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try await sut.getCharacter(identifier: 1)

        // Then
        let saveCount = memoryDataSourceMock.saveCharacterCallCount
        let savedValue = memoryDataSourceMock.saveCharacterLastValue
        #expect(saveCount == 1)
        #expect(savedValue == characterDTO)
    }

    @Test
    func callsRemoteDataSourceWithCorrectId() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .success(characterDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .success(characterDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .success(characterDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .success(characterDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .success(characterDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .success(characterDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == expected)
    }

    // MARK: - Error Tests

    @Test
    func propagatesRemoteErrorOnCacheMiss() async throws {
        // Given
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(TestError.network)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.getCharacter(identifier: 1)
        }
    }

    @Test
    func doesNotSaveToCacheOnRemoteError() async throws {
        // Given
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(TestError.network)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try? await sut.getCharacter(identifier: 1)

        // Then
        let saveCount = memoryDataSourceMock.saveCharacterCallCount
        #expect(saveCount == 0)
    }

    // MARK: - Get Characters (Paginated) - Cache Hit

    @Test
    func getCharactersReturnsCachedPageWhenAvailable() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        let expected = CharactersPage.stub()
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        memoryDataSourceMock.pageToReturn = responseDTO
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.getCharacters(page: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func getCharactersDoesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response")
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        memoryDataSourceMock.pageToReturn = responseDTO
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.charactersResult = .success(responseDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.charactersResult = .success(responseDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.charactersResult = .success(responseDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try await sut.getCharacters(page: 1)

        // Then
        let saveCount = memoryDataSourceMock.savePageCallCount
        let savedResponse = memoryDataSourceMock.savePageLastResponse
        let savedPage = memoryDataSourceMock.savePageLastPage
        #expect(saveCount == 1)
        #expect(savedResponse == responseDTO)
        #expect(savedPage == 1)
    }

    @Test
    func getCharactersTransformsPaginationInfo() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try loadJSON("characters_response_pagination")
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.charactersResult = .success(responseDTO)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

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
    func getCharactersPropagatesRemoteErrorOnCacheMiss() async throws {
        // Given
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.charactersResult = .failure(TestError.network)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.getCharacters(page: 1)
        }
    }

    @Test
    func getCharactersDoesNotSaveToCacheOnError() async throws {
        // Given
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.charactersResult = .failure(TestError.network)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try? await sut.getCharacters(page: 1)

        // Then
        let saveCount = memoryDataSourceMock.savePageCallCount
        #expect(saveCount == 0)
    }
}

// MARK: - Private

private extension CharacterRepositoryTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }
}

private enum TestError: Error {
    case network
}
