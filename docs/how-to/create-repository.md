# How To: Create Repository

Create a Repository that abstracts data access, transforms DTOs to Domain models, and optionally implements caching strategies.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- DataSources created (see [Create DataSource](create-datasource.md))

## Repository types

| Type | DataSources | Use case |
|------|-------------|----------|
| Remote only | `RemoteDataSource` | Simple API consumption, no caching |
| Local only | `MemoryDataSource` | Offline-first, local state management |
| Both (with cache) | `RemoteDataSource` + `MemoryDataSource` | Caching with configurable policy |

## File structure

```
Features/{Feature}/
├── Sources/
│   ├── Domain/
│   │   ├── Errors/
│   │   │   └── {Feature}Error.swift
│   │   ├── Models/
│   │   │   ├── {Name}.swift
│   │   └── Repositories/
│   │       └── {Name}RepositoryContract.swift
│   └── Data/
│       └── Repositories/
│           └── {Name}Repository.swift
└── Tests/
    ├── Unit/
    │   └── Data/
    │       └── {Name}RepositoryTests.swift
    └── Shared/
        └── Mocks/
            └── {Name}RepositoryMock.swift
```

---

## Common steps (all types)

### 1. Create Domain Model

> *"The basic symptom of an Anemic Domain Model is that at first blush it looks like the real thing... but there is hardly any behavior on these objects, making them little more than bags of getters and setters."*
> — Martin Fowler, [Anemic Domain Model](https://martinfowler.com/bliki/AnemicDomainModel.html)

Domain models **should have behavior** - unlike DTOs (which are intentionally anemic), domain models can include factory methods, computed properties, and business rules.

Create `Sources/Domain/Models/{Name}.swift`:

```swift
import Foundation

struct {Name}: Equatable {
    let id: Int
    let name: String
    let status: {Name}Status

    // Factory method - valid domain concept
    static func empty() -> {Name} {
        {Name}(id: 0, name: "", status: .unknown)
    }

    // Computed property - business logic
    var isActive: Bool {
        status == .active
    }
}

enum {Name}Status: String {
    case active = "Active"
    case inactive = "Inactive"
    case unknown

    init(from string: String) {
        self = Self(rawValue: string) ?? .unknown
    }
}
```

### 2. Create Domain Error

Create `Sources/Domain/Errors/{Feature}Error.swift`:

```swift
import ChallengeResources
import Foundation

public enum {Feature}Error: Error, Equatable, Sendable, LocalizedError {
    case loadFailed
    case notFound(identifier: Int)

    public var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "{feature}Error.loadFailed".localized()
        case .notFound(let identifier):
            return "{feature}Error.notFound %lld".localized(identifier)
        }
    }
}
```

---

## Option A: Remote only Repository

### 3A. Create Contract

Create `Sources/Domain/Repositories/{Name}RepositoryContract.swift`:

```swift
import Foundation

protocol {Name}RepositoryContract: Sendable {
    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name}
}
```

### 4A. Create Implementation

Create `Sources/Data/Repositories/{Name}Repository.swift`:

```swift
import ChallengeNetworking
import Foundation

struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract

    init(remoteDataSource: {Name}RemoteDataSourceContract) {
        self.remoteDataSource = remoteDataSource
    }

    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
        do {
            let dto = try await remoteDataSource.fetch{Name}(identifier: identifier)
            return dto.toDomain()
        } catch let error as HTTPError {
            throw mapHTTPError(error, identifier: identifier)
        } catch {
            throw .loadFailed
        }
    }
}

// MARK: - Error Mapping

private extension {Name}Repository {
    func mapHTTPError(_ error: HTTPError, identifier: Int) -> {Feature}Error {
        switch error {
        case .statusCode(404, _):
            .notFound(identifier: identifier)
        case .invalidURL, .invalidResponse, .statusCode:
            .loadFailed
        }
    }
}

// MARK: - DTO to Domain Mapping

private extension {Name}DTO {
    func toDomain() -> {Name} {
        {Name}(id: id, name: name, status: {Name}Status(from: status))
    }
}
```

### 5A. Create Mock

Create `Tests/Shared/Mocks/{Name}RepositoryMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed)
    private(set) var getCallCount = 0
    private(set) var lastIdentifier: Int?

    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
        getCallCount += 1
        lastIdentifier = identifier
        return try result.get()
    }
}
```

### 6A. Create tests

Create `Tests/Unit/Data/{Name}RepositoryTests.swift`:

```swift
import ChallengeCoreMocks
import ChallengeNetworking
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}RepositoryTests {
    private let remoteDataSourceMock = {Name}RemoteDataSourceMock()
    private let sut: {Name}Repository

    init() {
        sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)
    }

    // MARK: - Success Tests

    @Test("Returns transformed domain model on success")
    func returnsTransformedDomainModelOnSuccess() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Test", status: "Active")
        remoteDataSourceMock.result = .success(dto)

        // When
        let value = try await sut.get{Name}(identifier: 1)

        // Then
        #expect(value.id == 1)
        #expect(value.name == "Test")
        #expect(value.status == .active)
    }

    @Test("Transforms unknown status correctly")
    func transformsUnknownStatusCorrectly() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Test", status: "InvalidStatus")
        remoteDataSourceMock.result = .success(dto)

        // When
        let value = try await sut.get{Name}(identifier: 1)

        // Then
        #expect(value.status == .unknown)
    }

    // MARK: - Error Mapping Tests

    @Test("Maps HTTP 404 to notFound error")
    func mapsHTTP404ToNotFoundError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: {Feature}Error.notFound(identifier: 42)) {
            _ = try await sut.get{Name}(identifier: 42)
        }
    }

    @Test("Maps HTTP 500 to loadFailed error")
    func mapsHTTP500ToLoadFailedError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.statusCode(500, Data()))

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.get{Name}(identifier: 1)
        }
    }

    @Test("Maps generic error to loadFailed error")
    func mapsGenericErrorToLoadFailedError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(TestError.unknown)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.get{Name}(identifier: 1)
        }
    }
}

private enum TestError: Error {
    case unknown
}
```

---

## Option B: Local only Repository

### 3B. Create Contract

Create `Sources/Domain/Repositories/{Name}RepositoryContract.swift`:

```swift
import Foundation

protocol {Name}RepositoryContract: Sendable {
    func get{Name}(identifier: Int) async -> {Name}?
    func save{Name}(_ item: {Name}) async
}
```

### 4B. Create Implementation

Create `Sources/Data/Repositories/{Name}Repository.swift`:

```swift
import Foundation

struct {Name}Repository: {Name}RepositoryContract {
    private let memoryDataSource: {Name}MemoryDataSourceContract

    init(memoryDataSource: {Name}MemoryDataSourceContract) {
        self.memoryDataSource = memoryDataSource
    }

    func get{Name}(identifier: Int) async -> {Name}? {
        guard let dto = await memoryDataSource.get{Name}(identifier: identifier) else {
            return nil
        }
        return dto.toDomain()
    }

    func save{Name}(_ item: {Name}) async {
        await memoryDataSource.save{Name}(item.toDTO())
    }
}

// MARK: - Mapping

private extension {Name}DTO {
    func toDomain() -> {Name} {
        {Name}(id: id, name: name, status: {Name}Status(from: status))
    }
}

private extension {Name} {
    func toDTO() -> {Name}DTO {
        {Name}DTO(id: id, name: name, status: status.rawValue)
    }
}
```

### 5B. Create Mock

Create `Tests/Shared/Mocks/{Name}RepositoryMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
    var getResult: {Name}?
    private(set) var getCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var lastSaved: {Name}?

    func get{Name}(identifier: Int) async -> {Name}? {
        getCallCount += 1
        return getResult
    }

    func save{Name}(_ item: {Name}) async {
        saveCallCount += 1
        lastSaved = item
    }
}
```

### 6B. Create tests

Create `Tests/Unit/Data/{Name}RepositoryTests.swift`:

```swift
import Testing

@testable import Challenge{Feature}

struct {Name}RepositoryTests {
    private let memoryDataSourceMock = {Name}MemoryDataSourceMock()
    private let sut: {Name}Repository

    init() {
        sut = {Name}Repository(memoryDataSource: memoryDataSourceMock)
    }

    // MARK: - Get Tests

    @Test("Returns nil when not found in memory")
    func returnsNilWhenNotFoundInMemory() async {
        // Given
        memoryDataSourceMock.getResult = nil

        // When
        let result = await sut.get{Name}(identifier: 1)

        // Then
        #expect(result == nil)
    }

    @Test("Returns transformed domain model when found")
    func returnsTransformedDomainModelWhenFound() async {
        // Given
        let dto = {Name}DTO(id: 1, name: "Test", status: "Active")
        memoryDataSourceMock.getResult = dto

        // When
        let result = await sut.get{Name}(identifier: 1)

        // Then
        #expect(result?.id == 1)
        #expect(result?.status == .active)
    }

    // MARK: - Save Tests

    @Test("Saves item to memory data source")
    func savesItemToMemoryDataSource() async {
        // Given
        let item = {Name}(id: 1, name: "Test", status: .active)

        // When
        await sut.save{Name}(item)

        // Then
        #expect(memoryDataSourceMock.saveCallCount == 1)
        #expect(memoryDataSourceMock.lastSaved?.id == 1)
    }
}
```

---

## Option C: Both DataSources with CachePolicy

`CachePolicy` is defined in `ChallengeCore` (`Libraries/Core/Sources/Data/CachePolicy.swift`) and shared across all features — no need to create it per feature.

### 3C. Create Contract

Create `Sources/Domain/Repositories/{Name}RepositoryContract.swift`:

```swift
import ChallengeCore
import Foundation

protocol {Name}RepositoryContract: Sendable {
    func get{Name}Detail(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name}
}
```

> **Note:** Use `Detail` suffix for single-item methods to distinguish from list methods (`get{Name}Detail` vs `get{Name}s`).

### 4C. Create Implementation

Create `Sources/Data/Repositories/{Name}Repository.swift`:

```swift
import ChallengeCore
import ChallengeNetworking
import Foundation

struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract
    private let memoryDataSource: {Name}MemoryDataSourceContract

    init(
        remoteDataSource: {Name}RemoteDataSourceContract,
        memoryDataSource: {Name}MemoryDataSourceContract
    ) {
        self.remoteDataSource = remoteDataSource
        self.memoryDataSource = memoryDataSource
    }

    func get{Name}Detail(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        switch cachePolicy {
        case .localFirst:
            try await get{Name}DetailLocalFirst(identifier: identifier)
        case .remoteFirst:
            try await get{Name}DetailRemoteFirst(identifier: identifier)
        case .none:
            try await get{Name}DetailNoCache(identifier: identifier)
        }
    }
}

// MARK: - Remote Fetch Helper

private extension {Name}Repository {
    func fetchFromRemote(identifier: Int) async throws({Feature}Error) -> {Name}DTO {
        do {
            return try await remoteDataSource.fetch{Name}(identifier: identifier)
        } catch let error as HTTPError {
            throw mapHTTPError(error, identifier: identifier)
        } catch {
            throw .loadFailed
        }
    }
}

// MARK: - Cache Strategies

private extension {Name}Repository {
    func get{Name}DetailLocalFirst(identifier: Int) async throws({Feature}Error) -> {Name} {
        if let cached = await memoryDataSource.get{Name}Detail(identifier: identifier) {
            return cached.toDomain()
        }
        let dto = try await fetchFromRemote(identifier: identifier)
        await memoryDataSource.save{Name}Detail(dto)
        return dto.toDomain()
    }

    func get{Name}DetailRemoteFirst(identifier: Int) async throws({Feature}Error) -> {Name} {
        do {
            let dto = try await fetchFromRemote(identifier: identifier)
            await memoryDataSource.save{Name}Detail(dto)
            return dto.toDomain()
        } catch {
            if let cached = await memoryDataSource.get{Name}Detail(identifier: identifier) {
                return cached.toDomain()
            }
            throw error
        }
    }

    func get{Name}DetailNoCache(identifier: Int) async throws({Feature}Error) -> {Name} {
        let dto = try await fetchFromRemote(identifier: identifier)
        return dto.toDomain()
    }
}

// MARK: - Error Mapping

private extension {Name}Repository {
    func mapHTTPError(_ error: HTTPError, identifier: Int) -> {Feature}Error {
        switch error {
        case .statusCode(404, _):
            .notFound(identifier: identifier)
        case .invalidURL, .invalidResponse, .statusCode:
            .loadFailed
        }
    }
}

// MARK: - DTO to Domain Mapping

private extension {Name}DTO {
    func toDomain() -> {Name} {
        {Name}(id: id, name: name, status: {Name}Status(from: status))
    }
}
```

### 5C. Create Mock

Create `Tests/Shared/Mocks/{Name}RepositoryMock.swift`:

```swift
import ChallengeCore
import Foundation

@testable import Challenge{Feature}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed)
    private(set) var get{Name}DetailCallCount = 0
    private(set) var lastRequestedIdentifier: Int?
    private(set) var last{Name}DetailCachePolicy: CachePolicy?

    func get{Name}Detail(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        get{Name}DetailCallCount += 1
        lastRequestedIdentifier = identifier
        last{Name}DetailCachePolicy = cachePolicy
        return try result.get()
    }
}
```

### 6C. Create tests

Create `Tests/Unit/Data/{Name}RepositoryTests.swift`:

```swift
import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworking
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}RepositoryTests {
    private let remoteDataSourceMock = {Name}RemoteDataSourceMock()
    private let memoryDataSourceMock = {Name}MemoryDataSourceMock()
    private let sut: {Name}Repository

    init() {
        sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )
    }

    // MARK: - LocalFirst Policy

    @Test("LocalFirst returns cached item when available")
    func localFirstReturnsCachedWhenAvailable() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Cached", status: "Active")
        memoryDataSourceMock.detailToReturn = dto

        // When
        let value = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value.name == "Cached")
        #expect(remoteDataSourceMock.fetchCallCount == 0)
    }

    @Test("LocalFirst does not call remote when cache hit")
    func localFirstDoesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Cached", status: "Active")
        memoryDataSourceMock.detailToReturn = dto

        // When
        _ = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCallCount == 0)
    }

    @Test("LocalFirst fetches from remote when cache miss")
    func localFirstFetchesFromRemoteWhenCacheMiss() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Remote", status: "Active")
        remoteDataSourceMock.result = .success(dto)

        // When
        let value = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value.name == "Remote")
        #expect(remoteDataSourceMock.fetchCallCount == 1)
    }

    @Test("LocalFirst saves to cache after remote fetch")
    func localFirstSavesToCacheAfterRemoteFetch() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Remote", status: "Active")
        remoteDataSourceMock.result = .success(dto)

        // When
        _ = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(memoryDataSourceMock.save{Name}DetailCallCount == 1)
    }

    // MARK: - RemoteFirst Policy

    @Test("RemoteFirst always fetches from remote")
    func remoteFirstAlwaysFetchesFromRemote() async throws {
        // Given
        let cachedDTO = {Name}DTO(id: 1, name: "Cached", status: "Inactive")
        let remoteDTO = {Name}DTO(id: 1, name: "Fresh", status: "Active")
        memoryDataSourceMock.detailToReturn = cachedDTO
        remoteDataSourceMock.result = .success(remoteDTO)

        // When
        let value = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value.name == "Fresh")
        #expect(remoteDataSourceMock.fetchCallCount == 1)
    }

    @Test("RemoteFirst saves to cache after remote fetch")
    func remoteFirstSavesToCacheAfterRemoteFetch() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Fresh", status: "Active")
        remoteDataSourceMock.result = .success(dto)

        // When
        _ = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(memoryDataSourceMock.save{Name}DetailCallCount == 1)
    }

    @Test("RemoteFirst falls back to cache on error")
    func remoteFirstFallsBackToCacheOnError() async throws {
        // Given
        let cachedDTO = {Name}DTO(id: 1, name: "Cached", status: "Active")
        memoryDataSourceMock.detailToReturn = cachedDTO
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When
        let value = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value.name == "Cached")
    }

    @Test("RemoteFirst throws error when remote fails and no cache")
    func remoteFirstThrowsErrorWhenRemoteFailsAndNoCache() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .remoteFirst)
        }
    }

    // MARK: - None Policy

    @Test("None policy only fetches from remote")
    func nonePolicyOnlyFetchesFromRemote() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Remote", status: "Active")
        remoteDataSourceMock.result = .success(dto)

        // When
        let value = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .none)

        // Then
        #expect(value.name == "Remote")
        #expect(remoteDataSourceMock.fetchCallCount == 1)
    }

    @Test("None policy does not save to cache")
    func nonePolicyDoesNotSaveToCache() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Remote", status: "Active")
        remoteDataSourceMock.result = .success(dto)

        // When
        _ = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .none)

        // Then
        #expect(memoryDataSourceMock.save{Name}DetailCallCount == 0)
    }

    @Test("None policy does not check cache")
    func nonePolicyDoesNotCheckCache() async throws {
        // Given
        let cachedDTO = {Name}DTO(id: 1, name: "Cached", status: "Inactive")
        let remoteDTO = {Name}DTO(id: 1, name: "Remote", status: "Active")
        memoryDataSourceMock.detailToReturn = cachedDTO
        remoteDataSourceMock.result = .success(remoteDTO)

        // When
        let value = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .none)

        // Then
        #expect(value.name == "Remote")
        #expect(memoryDataSourceMock.get{Name}DetailCallCount == 0)
    }

    // MARK: - Error Mapping Tests

    @Test("Maps HTTP 404 to notFound error")
    func mapsHTTP404ToNotFoundError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.statusCode(404, Data()))

        // When / Then
        await #expect(throws: {Feature}Error.notFound(identifier: 42)) {
            _ = try await sut.get{Name}Detail(identifier: 42, cachePolicy: .localFirst)
        }
    }

    @Test("Maps HTTP 500 to loadFailed error")
    func mapsHTTP500ToLoadFailedError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.statusCode(500, Data()))

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .localFirst)
        }
    }

    @Test("Does not save to cache when remote fails")
    func doesNotSaveToCacheWhenRemoteFails() async throws {
        // Given
        remoteDataSourceMock.result = .failure(HTTPError.invalidResponse)

        // When
        _ = try? await sut.get{Name}Detail(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(memoryDataSourceMock.save{Name}DetailCallCount == 0)
    }
}
```

---

## Add localized strings

Add to `Shared/Resources/Sources/Resources/Localizable.xcstrings`:

```json
"{feature}Error.loadFailed": "Failed to load data",
"{feature}Error.notFound %lld": "Item with ID %lld not found"
```

## Generate and verify

```bash
./generate.sh
```

## Next steps

- [Create UseCase](create-usecase.md) - Create business logic using this Repository

## See also

- [Create DataSource](create-datasource.md)
- [Project Structure](../ProjectStructure.md)
