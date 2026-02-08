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

    // MARK: - LocalFirst Policy

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

    // MARK: - RemoteFirst Policy

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
        await #expect(throws: CharacterError.loadFailed()) {
            _ = try await sut.getCharacter(identifier: 1, cachePolicy: .remoteFirst)
        }
    }

    // MARK: - NoCache Policy

    @Test("NoCache policy only fetches from remote")
    func noCachePolicyOnlyFetchesFromRemote() async throws {
        // Given
        let remoteDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(remoteDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .noCache)

        // Then
        #expect(value == Character.stub())
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
    }

    @Test("NoCache policy does not save to cache")
    func noCachePolicyDoesNotSaveToCache() async throws {
        // Given
        let remoteDTO: CharacterDTO = try loadJSON("character")
        remoteDataSourceMock.result = .success(remoteDTO)

        // When
        _ = try await sut.getCharacter(identifier: 1, cachePolicy: .noCache)

        // Then
        #expect(memoryDataSourceMock.saveCharacterCallCount == 0)
    }

    @Test("NoCache policy does not check cache")
    func noCachePolicyDoesNotCheckCache() async throws {
        // Given
        let cachedDTO: CharacterDTO = try loadJSON("character")
        let remoteDTO: CharacterDTO = try loadJSON("character_dead")
        memoryDataSourceMock.characterToReturn = cachedDTO
        remoteDataSourceMock.result = .success(remoteDTO)

        // When
        let value = try await sut.getCharacter(identifier: 1, cachePolicy: .noCache)

        // Then
        #expect(value.status == .dead)
        #expect(memoryDataSourceMock.getCharacterCallCount == 0)
    }

    // MARK: - Error Handling Tests

    @Test("Does not save to cache when remote fetch fails")
    func doesNotSaveToCacheOnRemoteError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When
        _ = try? await sut.getCharacter(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(memoryDataSourceMock.saveCharacterCallCount == 0)
    }
}

// MARK: - Private

private extension CharacterRepositoryTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }
}
