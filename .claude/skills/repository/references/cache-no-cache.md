# Cache Strategy: noCache

Implementation and tests for a repository that **only** uses the `noCache` strategy (no `CachePolicy` parameter — always remote, no cache interaction).

Use this when the user chose a **single fixed** `noCache` strategy instead of all configurable. This is functionally similar to a Remote Only repository but injects both DataSources (useful if cache may be added later).

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## Behavior

```
Always fetch from remote → return (no cache read or write)
```

## Implementation

```swift
import ChallengeCore
import ChallengeNetworking

struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract
    private let mapper = {Name}Mapper()
    private let errorMapper = {Name}ErrorMapper()

    init(remoteDataSource: {Name}RemoteDataSourceContract) {
        self.remoteDataSource = remoteDataSource
    }

    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
        do {
            let dto = try await remoteDataSource.fetch{Name}(identifier: identifier)
            return mapper.map(dto)
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
    @Test("Fetches from remote")
    func fetchesFromRemote() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(try loadJSON("{name}"))
        let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

        // When
        let value = try await sut.get{Name}(identifier: 1)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
    }

    @Test("Maps API error to domain error")
    func mapsAPIErrorToDomainError() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(.notFound)
        let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

        // When / Then
        await #expect(throws: {Feature}Error.notFound(identifier: 1)) {
            _ = try await sut.get{Name}(identifier: 1)
        }
    }

    @Test("Maps generic error to loadFailed")
    func mapsGenericErrorToLoadFailed() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(GenericTestError.unknown)
        let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

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
