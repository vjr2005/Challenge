# How To: Create Repository

Create a Repository that abstracts data access, transforms DTOs to Domain models, and optionally implements caching strategies.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- DataSources created (see [Create DataSource](create-datasource.md))

## Repository types

| Type | DataSources | Use case |
|------|-------------|----------|
| Remote only | `RemoteDataSource` | Simple API consumption, no caching |
| Local only (memory) | `MemoryDataSource` | Offline-first, local state management |
| Local only (persistent) | `LocalDataSource` | UserDefaults-backed storage (e.g., recent searches) |
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

public enum {Feature}Error: Error, Equatable, LocalizedError {
    case loadFailed(description: String = "")
    case notFound(identifier: Int)

    public static func == (lhs: {Feature}Error, rhs: {Feature}Error) -> Bool {
        switch (lhs, rhs) {
        case (.loadFailed, .loadFailed):
            true
        case let (.notFound(lhsId), .notFound(rhsId)):
            lhsId == rhsId
        default:
            false
        }
    }

    public var errorDescription: String? {
        switch self {
        case .loadFailed:
            "{feature}Error.loadFailed".localized()
        case .notFound(let identifier):
            "{feature}Error.notFound %lld".localized(identifier)
        }
    }
}

extension {Feature}Error: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .loadFailed(let description):
            description
        case .notFound(let identifier):
            "notFound(identifier: \(identifier))"
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
import ChallengeCore
import ChallengeNetworking
import Foundation

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

### 5A. Create Mock

Create `Tests/Shared/Mocks/{Name}RepositoryMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
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

    // MARK: - Error Handling Tests

    @Test("Maps generic error to loadFailed error")
    func mapsGenericErrorToLoadFailedError() async throws {
        // Given
        remoteDataSourceMock.result = .failure(TestError.unknown)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed()) {
            _ = try await sut.get{Name}(identifier: 1)
        }
    }
}

private enum TestError: Error {
    case unknown
}
```

> **Note:** HTTP error mapping tests (404 → notFound, 500 → loadFailed, etc.) belong in `{Name}ErrorMapperTests`, not in repository tests. Repository tests only verify generic error handling and data access behavior.

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
    private let localDataSource: {Name}LocalDataSourceContract

    init(localDataSource: {Name}LocalDataSourceContract) {
        self.localDataSource = localDataSource
    }

    func get{Name}(identifier: Int) async -> {Name}? {
        guard let dto = await localDataSource.get{Name}(identifier: identifier) else {
            return nil
        }
        return dto.toDomain()
    }

    func save{Name}(_ item: {Name}) async {
        await localDataSource.save{Name}(item.toDTO())
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
    private let localDataSourceMock = {Name}LocalDataSourceMock()
    private let sut: {Name}Repository

    init() {
        sut = {Name}Repository(localDataSource: localDataSourceMock)
    }

    // MARK: - Get Tests

    @Test("Returns nil when not found in local data source")
    func returnsNilWhenNotFound() async {
        // Given
        localDataSourceMock.getResult = nil

        // When
        let result = await sut.get{Name}(identifier: 1)

        // Then
        #expect(result == nil)
    }

    @Test("Returns transformed domain model when found")
    func returnsTransformedDomainModelWhenFound() async {
        // Given
        let dto = {Name}DTO(id: 1, name: "Test", status: "Active")
        localDataSourceMock.getResult = dto

        // When
        let result = await sut.get{Name}(identifier: 1)

        // Then
        #expect(result?.id == 1)
        #expect(result?.status == .active)
    }

    // MARK: - Save Tests

    @Test("Saves item to local data source")
    func savesItemToLocalDataSource() async {
        // Given
        let item = {Name}(id: 1, name: "Test", status: .active)

        // When
        await sut.save{Name}(item)

        // Then
        #expect(localDataSourceMock.saveCallCount == 1)
        #expect(localDataSourceMock.lastSaved?.id == 1)
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

    func get{Name}Detail(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        switch cachePolicy {
        case .localFirst:
            try await get{Name}DetailLocalFirst(identifier: identifier)
        case .remoteFirst:
            try await get{Name}DetailRemoteFirst(identifier: identifier)
        case .noCache:
            try await get{Name}DetailNoCache(identifier: identifier)
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
    func get{Name}DetailLocalFirst(identifier: Int) async throws({Feature}Error) -> {Name} {
        if let cached = await localDataSource.get{Name}Detail(identifier: identifier) {
            return mapper.map(cached)
        }
        let dto = try await fetchFromRemote(identifier: identifier)
        await localDataSource.save{Name}Detail(dto)
        return mapper.map(dto)
    }

    func get{Name}DetailRemoteFirst(identifier: Int) async throws({Feature}Error) -> {Name} {
        do {
            let dto = try await fetchFromRemote(identifier: identifier)
            await localDataSource.save{Name}Detail(dto)
            return mapper.map(dto)
        } catch {
            if let cached = await localDataSource.get{Name}Detail(identifier: identifier) {
                return mapper.map(cached)
            }
            throw error
        }
    }

    func get{Name}DetailNoCache(identifier: Int) async throws({Feature}Error) -> {Name} {
        let dto = try await fetchFromRemote(identifier: identifier)
        return mapper.map(dto)
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
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
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
    private let localDataSourceMock = {Name}LocalDataSourceMock()
    private let sut: {Name}Repository

    init() {
        sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            localDataSource: localDataSourceMock
        )
    }

    // MARK: - LocalFirst Policy

    @Test("LocalFirst returns cached item when available")
    func localFirstReturnsCachedWhenAvailable() async throws {
        // Given
        let dto = {Name}DTO(id: 1, name: "Cached", status: "Active")
        localDataSourceMock.detailToReturn = dto

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
        localDataSourceMock.detailToReturn = dto

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
        #expect(localDataSourceMock.save{Name}DetailCallCount == 1)
    }

    // MARK: - RemoteFirst Policy

    @Test("RemoteFirst always fetches from remote")
    func remoteFirstAlwaysFetchesFromRemote() async throws {
        // Given
        let cachedDTO = {Name}DTO(id: 1, name: "Cached", status: "Inactive")
        let remoteDTO = {Name}DTO(id: 1, name: "Fresh", status: "Active")
        localDataSourceMock.detailToReturn = cachedDTO
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
        #expect(localDataSourceMock.save{Name}DetailCallCount == 1)
    }

    @Test("RemoteFirst falls back to cache on error")
    func remoteFirstFallsBackToCacheOnError() async throws {
        // Given
        let cachedDTO = {Name}DTO(id: 1, name: "Cached", status: "Active")
        localDataSourceMock.detailToReturn = cachedDTO
        remoteDataSourceMock.result = .failure(APIError.invalidResponse)

        // When
        let value = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value.name == "Cached")
    }

    @Test("RemoteFirst throws error when remote fails and no cache")
    func remoteFirstThrowsErrorWhenRemoteFailsAndNoCache() async throws {
        // Given
        remoteDataSourceMock.result = .failure(APIError.invalidResponse)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed()) {
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
        let value = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .noCache)

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
        _ = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .noCache)

        // Then
        #expect(localDataSourceMock.save{Name}DetailCallCount == 0)
    }

    @Test("None policy does not check cache")
    func nonePolicyDoesNotCheckCache() async throws {
        // Given
        let cachedDTO = {Name}DTO(id: 1, name: "Cached", status: "Inactive")
        let remoteDTO = {Name}DTO(id: 1, name: "Remote", status: "Active")
        localDataSourceMock.detailToReturn = cachedDTO
        remoteDataSourceMock.result = .success(remoteDTO)

        // When
        let value = try await sut.get{Name}Detail(identifier: 1, cachePolicy: .noCache)

        // Then
        #expect(value.name == "Remote")
        #expect(localDataSourceMock.get{Name}DetailCallCount == 0)
    }

    // MARK: - Error Handling Tests

    @Test("Does not save to cache when remote fails")
    func doesNotSaveToCacheWhenRemoteFails() async throws {
        // Given
        remoteDataSourceMock.result = .failure(APIError.invalidResponse)

        // When
        _ = try? await sut.get{Name}Detail(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(localDataSourceMock.save{Name}DetailCallCount == 0)
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
