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
    private let memoryDataSourceMock = CharacterMemoryDataSourceMock()
    private let sut: CharacterRepository

    // MARK: - Initialization

    init() {
        sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
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

    // MARK: - Cache Wiring

    @Test("Saves to cache after successful remote fetch")
    func savesToCacheAfterRemoteFetch() async throws {
        // Given
        let characterDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(characterDTO)

        // When
        _ = try await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(await memoryDataSourceMock.saveCharacterCallCount == 1)
        #expect(await memoryDataSourceMock.saveCharacterLastValue == characterDTO)
    }

    // MARK: - Error Handling

    @Test("Does not save to cache when remote fetch fails")
    func doesNotSaveToCacheOnRemoteError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(APIError.invalidResponse)

        // When
        _ = try? await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(await memoryDataSourceMock.saveCharacterCallCount == 0)
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
