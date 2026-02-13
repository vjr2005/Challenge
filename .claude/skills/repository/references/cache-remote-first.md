# Cache Strategy: remoteFirst

Implementation and tests for a repository that **only** uses the `remoteFirst` cache strategy (no `CachePolicy` parameter — always remoteFirst).

Use this when the user chose a **single fixed** `remoteFirst` strategy instead of all configurable.

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## Behavior

```
Remote success → save to cache → return
Remote error   → cache hit  → return cached data (silent fallback)
Remote error   → cache miss → throw error
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
    private let cacheExecutor = CachePolicyExecutor()

    init(
        remoteDataSource: {Name}RemoteDataSourceContract,
        memoryDataSource: {Name}LocalDataSourceContract
    ) {
        self.remoteDataSource = remoteDataSource
        self.memoryDataSource = memoryDataSource
    }

    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
        try await cacheExecutor.execute(
            policy: .remoteFirst,
            fetchFromRemote: { try await remoteDataSource.fetch{Name}(identifier: identifier) },
            getFromCache: { await memoryDataSource.get{Name}(identifier: identifier) },
            saveToCache: { await memoryDataSource.save{Name}($0) },
            mapper: { mapper.map($0) },
            errorMapper: { errorMapper.map({Name}ErrorMapperInput(error: $0, identifier: identifier)) }
        )
    }
}
```

## Tests

Cache strategy logic is tested centrally in `CachePolicyExecutorTests`. Repository tests focus on **wiring** and **error mapping**.

```swift
import ChallengeCore
import ChallengeNetworking
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RepositoryTests {
    @Test("Fetches from remote and maps to domain model")
    func fetchesFromRemoteAndMapsToDomainModel() async throws {
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
        let value = try await sut.get{Name}(identifier: 1)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
    }

    @Test("Throws error when remote fails and cache is empty")
    func throwsErrorWhenRemoteFailsAndCacheIsEmpty() async throws {
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
            _ = try await sut.get{Name}(identifier: 1)
        }
    }
}
```
