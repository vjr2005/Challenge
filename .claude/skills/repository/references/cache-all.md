# Cache Strategy: All Configurable (CachePolicy)

Implementation and tests for a repository that accepts a `CachePolicy` parameter and delegates cache strategy execution to `CachePolicyExecutor`.

This is the **recommended** approach — callers decide the policy per request.

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## Contract

```swift
import ChallengeCore

nonisolated protocol {Name}RepositoryContract: Sendable {
    @concurrent func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name}
}
```

## Implementation

```swift
import ChallengeCore
import ChallengeNetworking

nonisolated struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract
    private let memoryDataSource: {Name}LocalDataSourceContract
    private let mapper = {Name}Mapper()
    private let errorMapper = {Name}ErrorMapper()
    private let cacheExecutor = CachePolicyExecutor()

    init(
        remoteDataSource: {Name}RemoteDataSourceContract,
        memoryDataSource: {Name}LocalDataSourceContract
    ) {
        self.remoteDataSource = remoteDataSource
        self.memoryDataSource = memoryDataSource
    }

    @concurrent func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        try await cacheExecutor.execute(
            policy: cachePolicy,
            fetchFromRemote: { try await remoteDataSource.fetch{Name}(identifier: identifier) },
            getFromCache: { await memoryDataSource.get{Name}(identifier: identifier) },
            saveToCache: { await memoryDataSource.save{Name}($0) },
            mapper: { mapper.map($0) },
            errorMapper: { errorMapper.map({Name}ErrorMapperInput(error: $0, identifier: identifier)) }
        )
    }
}
```

## Mock

```swift
import ChallengeCore
import Foundation

@testable import {AppName}{Feature}

nonisolated final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
    private(set) var get{Name}CallCount = 0
    private(set) var lastRequestedIdentifier: Int?
    private(set) var lastCachePolicy: CachePolicy?

    @concurrent func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        get{Name}CallCount += 1
        lastRequestedIdentifier = identifier
        lastCachePolicy = cachePolicy
        return try result.get()
    }
}
```

## Tests

Cache strategy logic is tested centrally in `CachePolicyExecutorTests`. Repository tests focus on **wiring** (correct data source calls, mapper usage), **cache wiring**, and **error mapping**.

```swift
import ChallengeCore
import ChallengeNetworking
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RepositoryTests {
    // MARK: - Remote Fetch

    @Test("Fetches from remote and maps to domain model")
    func fetchesFromRemoteAndMapsToDomainModel() async throws {
        // Given
        let remoteDTO: {Name}DTO = try loadJSON("{name}")
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(remoteDTO)
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(identifier: 1, cachePolicy: .noCache)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
    }

    // MARK: - Cache Wiring

    @Test("Saves to cache after successful remote fetch")
    func savesToCacheAfterRemoteFetch() async throws {
        // Given
        let remoteDTO: {Name}DTO = try loadJSON("{name}")
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(remoteDTO)
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try await sut.get{Name}(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(await memoryDataSourceMock.saveCallCount == 1)
        #expect(await memoryDataSourceMock.lastSavedValue == remoteDTO)
    }

    // MARK: - Error Handling

    @Test("Does not save to cache when remote fetch fails")
    func doesNotSaveToCacheOnRemoteError() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(.invalidResponse)
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try? await sut.get{Name}(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(await memoryDataSourceMock.saveCallCount == 0)
    }

    @Test("Maps API error to domain error")
    func mapsAPIErrorToDomainError() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(.notFound)
        let memoryDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When / Then
        await #expect(throws: {Feature}Error.notFound(identifier: 1)) {
            _ = try await sut.get{Name}(identifier: 1, cachePolicy: .noCache)
        }
    }
}
```

---

## Complete Example: Character

Real-world example with typed throws, ISP-separated contracts, and full cache strategy.

See the Character feature in the codebase:
- Contract: `Features/Character/Sources/Domain/Repositories/CharacterRepositoryContract.swift`
- Implementation: `Features/Character/Sources/Data/Repositories/CharacterRepository.swift`
- Tests: `Features/Character/Tests/Unit/Data/CharacterRepositoryTests.swift`
