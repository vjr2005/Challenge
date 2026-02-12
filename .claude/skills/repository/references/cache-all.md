# Cache Strategy: All Configurable (CachePolicy)

Implementation and tests for a repository that accepts a `CachePolicy` parameter and implements all three strategies: `localFirst`, `remoteFirst`, and `noCache`.

This is the **recommended** approach — callers decide the policy per request.

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## Contract

```swift
import ChallengeCore

protocol {Name}RepositoryContract: Sendable {
    func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name}
}
```

## Implementation

```swift
import ChallengeCore
import ChallengeNetworking

struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract
    private let memoryDataSource: {Name}LocalDataSourceContract
    private let mapper = {Name}Mapper()
    private let errorMapper = {Name}ErrorMapper()

    init(
        remoteDataSource: {Name}RemoteDataSourceContract,
        memoryDataSource: {Name}LocalDataSourceContract
    ) {
        self.remoteDataSource = remoteDataSource
        self.memoryDataSource = memoryDataSource
    }

    func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        switch cachePolicy {
        case .localFirst:
            try await get{Name}LocalFirst(identifier: identifier)
        case .remoteFirst:
            try await get{Name}RemoteFirst(identifier: identifier)
        case .noCache:
            try await get{Name}NoCache(identifier: identifier)
        }
    }
}

// MARK: - Remote Fetch Helper

private extension {Name}Repository {
    func fetchFromRemote(identifier: Int) async throws({Feature}Error) -> {Name}DTO {
        do {
            return try await remoteDataSource.fetch{Name}(identifier: identifier)
        } catch {
            throw errorMapper.map({Name}ErrorMapperInput(error: error, identifier: identifier))
        }
    }
}

// MARK: - Cache Strategies

private extension {Name}Repository {
    func get{Name}LocalFirst(identifier: Int) async throws({Feature}Error) -> {Name} {
        if let cached = await memoryDataSource.get{Name}(identifier: identifier) {
            return mapper.map(cached)
        }
        let dto = try await fetchFromRemote(identifier: identifier)
        await memoryDataSource.save{Name}(dto)
        return mapper.map(dto)
    }

    func get{Name}RemoteFirst(identifier: Int) async throws({Feature}Error) -> {Name} {
        do {
            let dto = try await fetchFromRemote(identifier: identifier)
            await memoryDataSource.save{Name}(dto)
            return mapper.map(dto)
        } catch {
            if let cached = await memoryDataSource.get{Name}(identifier: identifier) {
                return mapper.map(cached)
            }
            throw error
        }
    }

    func get{Name}NoCache(identifier: Int) async throws({Feature}Error) -> {Name} {
        let dto = try await fetchFromRemote(identifier: identifier)
        return mapper.map(dto)
    }
}
```

## Mock

```swift
import ChallengeCore
import Foundation

@testable import {AppName}{Feature}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
    private(set) var get{Name}CallCount = 0
    private(set) var lastRequestedIdentifier: Int?
    private(set) var lastCachePolicy: CachePolicy?

    func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        get{Name}CallCount += 1
        lastRequestedIdentifier = identifier
        lastCachePolicy = cachePolicy
        return try result.get()
    }
}
```

## Tests

```swift
import ChallengeCore
import ChallengeNetworking
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RepositoryTests {
    // MARK: - LocalFirst Tests

    @Test("LocalFirst returns cached data when available")
    func localFirstReturnsCachedData() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        await memoryDataSourceMock.setItemToReturn(try loadJSON("{name}"))
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 0)
    }

    @Test("LocalFirst fetches from remote on cache miss and saves")
    func localFirstFetchesFromRemoteOnCacheMiss() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(try loadJSON("{name}"))
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
        #expect(await memoryDataSourceMock.saveCallCount == 1)
    }

    // MARK: - RemoteFirst Tests

    @Test("RemoteFirst fetches from remote and saves to cache")
    func remoteFirstFetchesFromRemote() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(try loadJSON("{name}"))
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        await memoryDataSourceMock.setItemToReturn(try loadJSON("{name}"))
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
        #expect(await memoryDataSourceMock.saveCallCount == 1)
    }

    @Test("RemoteFirst falls back to cache on error")
    func remoteFirstFallsBackToCache() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(.invalidResponse)
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        await memoryDataSourceMock.setItemToReturn(try loadJSON("{name}"))
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == expected)
    }

    @Test("RemoteFirst throws when remote fails and cache is empty")
    func remoteFirstThrowsWhenRemoteFailsAndCacheIsEmpty() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(.invalidResponse)
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed()) {
            _ = try await sut.get{Name}(identifier: 1, cachePolicy: .remoteFirst)
        }
    }

    // MARK: - NoCache Tests

    @Test("NoCache fetches from remote without saving")
    func noCacheFetchesFromRemoteWithoutSaving() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(try loadJSON("{name}"))
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        await memoryDataSourceMock.setItemToReturn(try loadJSON("{name}"))
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(identifier: 1, cachePolicy: .noCache)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
        #expect(await memoryDataSourceMock.saveCallCount == 0)
    }

    // MARK: - Error Handling

    @Test("Maps generic error to loadFailed")
    func mapsGenericErrorToLoadFailed() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(GenericTestError.unknown)
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed()) {
            _ = try await sut.get{Name}(identifier: 1, cachePolicy: .noCache)
        }
    }
}

private enum GenericTestError: Error {
    case unknown
}
```

---

## Complete Example: Character

Real-world example with typed throws, ISP-separated contracts, and full cache strategy.

See the Character feature in the codebase:
- Contract: `Features/Character/Sources/Domain/Repositories/CharacterRepositoryContract.swift`
- Implementation: `Features/Character/Sources/Data/Repositories/CharacterRepository.swift`
- Tests: `Features/Character/Tests/Unit/Data/CharacterRepositoryTests.swift`
