# Cache Strategy: localFirst

Implementation and tests for a repository that **only** uses the `localFirst` cache strategy (no `CachePolicy` parameter — always localFirst).

Use this when the user chose a **single fixed** `localFirst` strategy instead of all configurable.

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## Behavior

```
Cache hit  → return cached data (no remote call)
Cache miss → fetch from remote → save to cache → return
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

    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
        if let cached = await memoryDataSource.get{Name}(identifier: identifier) {
            return mapper.map(cached)
        }
        let dto = try await fetchFromRemote(identifier: identifier)
        await memoryDataSource.save{Name}(dto)
        return mapper.map(dto)
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
    @Test("Returns cached data when available")
    func returnsCachedDataWhenAvailable() async throws {
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
        let value = try await sut.get{Name}(identifier: 1)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 0)
    }

    @Test("Fetches from remote on cache miss and saves to cache")
    func fetchesFromRemoteOnCacheMissAndSaves() async throws {
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
        #expect(await memoryDataSourceMock.saveCallCount == 1)
    }

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
            _ = try await sut.get{Name}(identifier: 1)
        }
    }
}

private enum GenericTestError: Error {
    case unknown
}
```
