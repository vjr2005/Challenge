import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworking
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterRepositoryTests {
    // MARK: - Properties

    private let remoteDataSourceMock = CharacterRemoteDataSourceMock()
    private let volatileDataSourceMock = CharacterLocalDataSourceMock()
    private let persistenceDataSourceMock = CharacterLocalDataSourceMock()
    private let sut: CharacterRepository

    // MARK: - Initialization

    init() {
        sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            volatile: volatileDataSourceMock,
            persistence: persistenceDataSourceMock
        )
    }

    // MARK: - Remote Fetch

    @Test("Fetches from remote and maps to domain model")
    func fetchesFromRemoteAndMapsToDomainModel() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        let expected = Character.stub()
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .noCache)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
    }

    @Test("Passes correct identifier to remote data source")
    func passesCorrectIdentifierToRemote() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        _ = try await sut.getCharacter(identifier: 42, cachePolicy: .noCache)

        // Then
        #expect(remoteDataSourceMock.lastFetchedIdentifier == 42)
    }

    // MARK: - Cache Wiring

    @Test("Returns volatile cached value without calling remote")
    func returnsVolatileCachedValue() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        await volatileDataSourceMock.setCharacterToReturn(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == Character.stub())
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 0)
    }

    @Test("Falls back to persistence when volatile misses")
    func fallsBackToPersistenceWhenVolatileMisses() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        await persistenceDataSourceMock.setCharacterToReturn(characterDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == Character.stub())
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 0)
        #expect(await volatileDataSourceMock.saveCharacterCallCount == 1)
    }

    @Test("Saves to cache after successful remote fetch")
    func savesToCacheAfterRemoteFetch() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        _ = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(await volatileDataSourceMock.saveCharacterCallCount == 1)
        #expect(await volatileDataSourceMock.saveCharacterLastValue == characterDTO)
        #expect(await persistenceDataSourceMock.saveCharacterCallCount == 1)
        #expect(await persistenceDataSourceMock.saveCharacterLastValue == characterDTO)
    }

    // MARK: - Error Handling

    @Test("Does not save to cache when remote fetch fails")
    func doesNotSaveToCacheOnRemoteError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(APIError.invalidResponse)

        // When
        _ = try? await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(await volatileDataSourceMock.saveCharacterCallCount == 0)
        #expect(await persistenceDataSourceMock.saveCharacterCallCount == 0)
    }

    @Test("Maps API error to domain error")
    func mapsAPIErrorToDomainError() async {
        // Given
        remoteDataSourceMock.result = .failure(APIError.notFound)

        // When / Then
        await #expect(throws: CharacterError.notFound(identifier: 1)) {
            _ = try await sut.getCharacter(identifier: 1, cachePolicy: .noCache)
        }
    }
}

// MARK: - Private

private extension CharacterRepositoryTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }
}
