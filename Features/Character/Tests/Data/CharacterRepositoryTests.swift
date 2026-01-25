import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterRepositoryTests {
    private let testBundle = Bundle(for: BundleToken.self)

    // MARK: - Cache Hit Tests

    @Test
    func returnsCachedCharacterWhenAvailable() async throws {
        // Given
        let characterDTO: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
        let expected = Character.stub()
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        await MainActor.run { memoryDataSourceMock.characterToReturn = characterDTO }
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
        let characterDTO: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        await MainActor.run { memoryDataSourceMock.characterToReturn = characterDTO }
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
        let characterDTO: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
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
        let characterDTO: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
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
        let saveCount = await memoryDataSourceMock.saveCharacterCallCount
        let savedValue = await memoryDataSourceMock.saveCharacterLastValue
        #expect(saveCount == 1)
        #expect(savedValue == characterDTO)
    }

    @Test
    func callsRemoteDataSourceWithCorrectId() async throws {
        // Given
        let characterDTO: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
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
        let characterDTO: CharacterDTO = try testBundle.loadJSON("character_dead", as: CharacterDTO.self)
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
        let characterDTO: CharacterDTO = try testBundle.loadJSON("character_unknown_status", as: CharacterDTO.self)
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
        let saveCount = await memoryDataSourceMock.saveCharacterCallCount
        #expect(saveCount == 0)
    }

    // MARK: - Get Characters (Paginated) - Cache Hit

    @Test
    func getCharactersReturnsCachedPageWhenAvailable() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try testBundle.loadJSON("characters_response", as: CharactersResponseDTO.self)
        let expected = CharactersPage.stub()
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        await MainActor.run { memoryDataSourceMock.pageToReturn = responseDTO }
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
        let responseDTO: CharactersResponseDTO = try testBundle.loadJSON("characters_response", as: CharactersResponseDTO.self)
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        await MainActor.run { memoryDataSourceMock.pageToReturn = responseDTO }
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
        let responseDTO: CharactersResponseDTO = try testBundle.loadJSON("characters_response", as: CharactersResponseDTO.self)
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
        let responseDTO: CharactersResponseDTO = try testBundle.loadJSON("characters_response", as: CharactersResponseDTO.self)
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
        let responseDTO: CharactersResponseDTO = try testBundle.loadJSON("characters_response_two_results", as: CharactersResponseDTO.self)
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
        let saveCount = await memoryDataSourceMock.savePageCallCount
        let savedResponse = await memoryDataSourceMock.savePageLastResponse
        let savedPage = await memoryDataSourceMock.savePageLastPage
        #expect(saveCount == 1)
        #expect(savedResponse == responseDTO)
        #expect(savedPage == 1)
    }

    @Test
    func getCharactersTransformsPaginationInfo() async throws {
        // Given
        let responseDTO: CharactersResponseDTO = try testBundle.loadJSON("characters_response_pagination", as: CharactersResponseDTO.self)
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
        let saveCount = await memoryDataSourceMock.savePageCallCount
        #expect(saveCount == 0)
    }
}

private final class BundleToken {}

private enum TestError: Error {
    case network
}
