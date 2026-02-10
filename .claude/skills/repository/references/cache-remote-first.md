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
    private let localDataSource: {Name}LocalDataSourceContract
    private let mapper = {Name}Mapper()
    private let errorMapper = {Name}ErrorMapper()

    init(
        remoteDataSource: {Name}RemoteDataSourceContract,
        localDataSource: {Name}LocalDataSourceContract
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
        do {
            let dto = try await fetchFromRemote(identifier: identifier)
            await localDataSource.save{Name}(dto)
            return mapper.map(dto)
        } catch {
            if let cached = await localDataSource.get{Name}(identifier: identifier) {
                return mapper.map(cached)
            }
            throw error
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
```

## Tests

```swift
import ChallengeCore
import ChallengeNetworking
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RepositoryTests {
    @Test("Fetches from remote and saves to cache")
    func fetchesFromRemoteAndSavesToCache() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let localDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            localDataSource: localDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(identifier: 1)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
        #expect(localDataSourceMock.saveCallCount == 1)
    }

    @Test("Always calls remote even when cache has data")
    func alwaysCallsRemoteEvenWhenCacheHasData() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let localDataSourceMock = {Name}LocalDataSourceMock()
        localDataSourceMock.itemToReturn = .stub()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            localDataSource: localDataSourceMock
        )

        // When
        _ = try await sut.get{Name}(identifier: 1)

        // Then
        #expect(remoteDataSourceMock.fetchCallCount == 1)
    }

    @Test("Falls back to cache on remote error")
    func fallsBackToCacheOnRemoteError() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(.invalidResponse)
        let localDataSourceMock = {Name}LocalDataSourceMock()
        localDataSourceMock.itemToReturn = .stub()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            localDataSource: localDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(identifier: 1)

        // Then
        #expect(value == expected)
    }

    @Test("Throws error when remote fails and cache is empty")
    func throwsErrorWhenRemoteFailsAndCacheIsEmpty() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(.invalidResponse)
        let localDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            localDataSource: localDataSourceMock
        )

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed()) {
            _ = try await sut.get{Name}(identifier: 1)
        }
    }
}
```
