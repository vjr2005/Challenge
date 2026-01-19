---
name: repository
autoContext: true
description: Creates Repositories that abstract data access. Use when creating repositories, transforming DTOs to domain models, or implementing local-first caching.
---

# Skill: Repository

Guide for creating Repositories that abstract data access following Clean Architecture.

## When to use this skill

- Create a new Repository to abstract data sources
- Transform DTOs to Domain models
- Provide a clean API for Use Cases
- Implement caching with local-first policy

## File structure

```
Libraries/Features/{FeatureName}/
├── Sources/
│   ├── Domain/
│   │   ├── Models/
│   │   │   └── {Name}.swift                      # Domain model
│   │   └── Repositories/
│   │       └── {Name}RepositoryContract.swift    # Contract (protocol)
│   └── Data/
│       ├── DataSources/
│       │   ├── {Name}RemoteDataSource.swift      # Remote DataSource (see /datasource skill)
│       │   └── {Name}MemoryDataSource.swift      # Memory DataSource (see /datasource skill)
│       ├── DTOs/
│       │   └── {Name}DTO.swift                   # DTO (see /datasource skill)
│       └── Repositories/
│           └── {Name}Repository.swift            # Implementation
└── Tests/
    ├── Data/
    │   └── {Name}RepositoryTests.swift           # Repository tests
    └── Mocks/
        └── {Name}RepositoryMock.swift            # Mock for testing Use Cases
```

## Repository Scenarios

A Repository can be configured with:

| Scenario | DataSources | Use case |
|----------|-------------|----------|
| Remote only | `RemoteDataSource` | Simple API consumption |
| Local only | `MemoryDataSource` | Offline-first, local state |
| Both (local-first) | `RemoteDataSource` + `MemoryDataSource` | Caching with remote fallback |

---

## Common Components

### 1. Domain Model

```swift
struct {Name}: Equatable {
    let id: Int
    let name: String
    // Domain-specific properties
}
```

**Rules:**
- Located in `Domain/Models/`
- **Internal visibility** (not public)
- Conform to `Equatable`
- Use `let` properties (immutable)
- Contains only domain-relevant data (no API-specific fields)

### 2. Contract (Protocol) - Domain Layer

```swift
protocol {Name}RepositoryContract: Sendable {
    func get{Name}(id: Int) async throws -> {Name}
    func getAll{Name}s() async throws -> [{Name}]
}
```

**Rules:**
- Located in `Domain/Repositories/`
- `Contract` suffix in the name
- **Internal visibility** (not public)
- Conform to `Sendable`
- Methods are `async throws`
- **Return Domain models, NOT DTOs**

### 3. DTO to Domain Mapping

```swift
extension {Name}DTO {
    func toDomain() -> {Name} {
        {Name}(
            id: id,
            name: name
        )
    }
}
```

**Rules:**
- Extension on DTO, returns Domain model
- Located in the same file as the Repository implementation or in a separate `{Name}DTO+Domain.swift` file
- Keep mapping logic simple and pure

### 4. Mock (in Tests/Mocks/)

```swift
import Foundation

@testable import Challenge{FeatureName}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
    var result: Result<{Name}, Error> = .failure(NotConfiguredError.notConfigured)
    var allResult: Result<[{Name}], Error> = .failure(NotConfiguredError.notConfigured)
    private(set) var getCallCount = 0
    private(set) var getAllCallCount = 0
    private(set) var lastRequestedId: Int?

    func get{Name}(id: Int) async throws -> {Name} {
        getCallCount += 1
        lastRequestedId = id
        return try result.get()
    }

    func getAll{Name}s() async throws -> [{Name}] {
        getAllCallCount += 1
        return try allResult.get()
    }
}

private enum NotConfiguredError: Error {
    case notConfigured
}
```

**Rules:**
- `Mock` suffix in the name
- Located in `Tests/Mocks/`
- **Requires `@testable import`** to access internal types
- `@unchecked Sendable` if it has mutable state
- Separate result properties for each method
- Call tracking properties

---

## Scenario 1: Remote Only

Use when the repository only needs to fetch data from a remote API.

### Implementation

```swift
struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract

    init(remoteDataSource: {Name}RemoteDataSourceContract) {
        self.remoteDataSource = remoteDataSource
    }

    func get{Name}(id: Int) async throws -> {Name} {
        let dto = try await remoteDataSource.fetch{Name}(id: id)
        return dto.toDomain()
    }

    func getAll{Name}s() async throws -> [{Name}] {
        let dtos = try await remoteDataSource.fetchAll{Name}s()
        return dtos.map { $0.toDomain() }
    }
}
```

### Tests

```swift
import Foundation
import Testing

@testable import Challenge{FeatureName}

struct {Name}RepositoryTests {
    @Test
    func getsModelFromRemoteDataSource() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

        // When
        let value = try await sut.get{Name}(id: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func callsRemoteDataSourceWithCorrectId() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

        // When
        _ = try await sut.get{Name}(id: 42)

        // Then
        #expect(remoteDataSourceMock.fetchCallCount == 1)
        #expect(remoteDataSourceMock.lastFetchedId == 42)
    }

    @Test
    func propagatesRemoteDataSourceError() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(TestError.network)
        let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.get{Name}(id: 1)
        }
    }
}

private enum TestError: Error {
    case network
}
```

---

## Scenario 2: Local Only

Use when the repository only needs to manage local (in-memory) state.

### Implementation

```swift
struct {Name}Repository: {Name}RepositoryContract {
    private let memoryDataSource: {Name}MemoryDataSourceContract

    init(memoryDataSource: {Name}MemoryDataSourceContract) {
        self.memoryDataSource = memoryDataSource
    }

    func get{Name}(id: Int) async throws -> {Name} {
        guard let dto = await memoryDataSource.get{Name}(id: id) else {
            throw {Name}RepositoryError.notFound
        }
        return dto.toDomain()
    }

    func getAll{Name}s() async throws -> [{Name}] {
        let dtos = await memoryDataSource.getAll{Name}s()
        return dtos.map { $0.toDomain() }
    }

    func save{Name}(_ model: {Name}) async {
        let dto = model.toDTO()
        await memoryDataSource.save{Name}(dto)
    }
}

enum {Name}RepositoryError: Error {
    case notFound
}
```

### Domain to DTO Mapping (for saving)

```swift
extension {Name} {
    func toDTO() -> {Name}DTO {
        {Name}DTO(
            id: id,
            name: name
        )
    }
}
```

### Tests

```swift
import Foundation
import Testing

@testable import Challenge{FeatureName}

struct {Name}RepositoryTests {
    @Test
    func getsModelFromMemoryDataSource() async throws {
        // Given
        let expected = {Name}.stub()
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        await memoryDataSourceMock.save{Name}(.stub())
        let sut = {Name}Repository(memoryDataSource: memoryDataSourceMock)

        // When
        let value = try await sut.get{Name}(id: expected.id)

        // Then
        #expect(value == expected)
    }

    @Test
    func throwsNotFoundWhenItemDoesNotExist() async throws {
        // Given
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(memoryDataSource: memoryDataSourceMock)

        // When / Then
        await #expect(throws: {Name}RepositoryError.notFound) {
            _ = try await sut.get{Name}(id: 999)
        }
    }

    @Test
    func savesModelToMemoryDataSource() async throws {
        // Given
        let model = {Name}.stub()
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(memoryDataSource: memoryDataSourceMock)

        // When
        await sut.save{Name}(model)
        let value = await memoryDataSourceMock.get{Name}(id: model.id)

        // Then
        #expect(value == model.toDTO())
    }
}
```

---

## Scenario 3: Local-First (Both DataSources)

Use when the repository needs caching with remote fallback. The **local-first policy** means:

1. Check local cache first
2. If found in cache, return cached data
3. If not found, fetch from remote
4. Save to local cache
5. Return the data

### Implementation

```swift
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

    func get{Name}(id: Int) async throws -> {Name} {
        // 1. Check local cache first
        if let cachedDTO = await memoryDataSource.get{Name}(id: id) {
            return cachedDTO.toDomain()
        }

        // 2. Fetch from remote
        let dto = try await remoteDataSource.fetch{Name}(id: id)

        // 3. Save to cache
        await memoryDataSource.save{Name}(dto)

        // 4. Return domain model
        return dto.toDomain()
    }

    func getAll{Name}s() async throws -> [{Name}] {
        // 1. Check local cache first
        let cachedDTOs = await memoryDataSource.getAll{Name}s()
        if !cachedDTOs.isEmpty {
            return cachedDTOs.map { $0.toDomain() }
        }

        // 2. Fetch from remote
        let dtos = try await remoteDataSource.fetchAll{Name}s()

        // 3. Save to cache
        await memoryDataSource.save{Name}s(dtos)

        // 4. Return domain models
        return dtos.map { $0.toDomain() }
    }
}
```

### Tests

```swift
import Foundation
import Testing

@testable import Challenge{FeatureName}

struct {Name}RepositoryTests {
    // MARK: - Cache Hit Tests

    @Test
    func returnsCachedDataWhenAvailable() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        await memoryDataSourceMock.save{Name}(.stub())
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(id: expected.id)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 0)
    }

    @Test
    func doesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        await memoryDataSourceMock.save{Name}(.stub())
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try await sut.get{Name}(id: 1)

        // Then
        #expect(remoteDataSourceMock.fetchCallCount == 0)
    }

    // MARK: - Cache Miss Tests

    @Test
    func fetchesFromRemoteWhenCacheMiss() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(id: 1)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
    }

    @Test
    func savesToCacheAfterRemoteFetch() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try await sut.get{Name}(id: 1)
        let cachedValue = await memoryDataSourceMock.get{Name}(id: 1)

        // Then
        #expect(cachedValue == .stub())
        #expect(await memoryDataSourceMock.saveCallCount == 1)
    }

    // MARK: - Error Tests

    @Test
    func propagatesRemoteErrorOnCacheMiss() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(TestError.network)
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.get{Name}(id: 1)
        }
    }

    @Test
    func doesNotSaveToCacheOnRemoteError() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(TestError.network)
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try? await sut.get{Name}(id: 1)

        // Then
        #expect(await memoryDataSourceMock.saveCallCount == 0)
    }
}

private enum TestError: Error {
    case network
}
```

---

## Complete Example: Character (Local-First)

### Domain Model

```swift
// Sources/Domain/Models/Character.swift
struct Character: Equatable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
}

enum CharacterStatus: String, Sendable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown
}
```

### Contract

```swift
// Sources/Domain/Repositories/CharacterRepositoryContract.swift
protocol CharacterRepositoryContract: Sendable {
    func getCharacter(id: Int) async throws -> Character
}
```

### Implementation (Local-First)

```swift
// Sources/Data/Repositories/CharacterRepository.swift
struct CharacterRepository: CharacterRepositoryContract {
    private let remoteDataSource: CharacterRemoteDataSourceContract
    private let memoryDataSource: CharacterMemoryDataSourceContract

    init(
        remoteDataSource: CharacterRemoteDataSourceContract,
        memoryDataSource: CharacterMemoryDataSourceContract
    ) {
        self.remoteDataSource = remoteDataSource
        self.memoryDataSource = memoryDataSource
    }

    func getCharacter(id: Int) async throws -> Character {
        // Check cache first
        if let cachedDTO = await memoryDataSource.getCharacter(id: id) {
            return cachedDTO.toDomain()
        }

        // Fetch from remote
        let dto = try await remoteDataSource.fetchCharacter(id: id)

        // Save to cache
        await memoryDataSource.saveCharacter(dto)

        return dto.toDomain()
    }
}

extension CharacterDTO {
    func toDomain() -> Character {
        Character(
            id: id,
            name: name,
            status: CharacterStatus(rawValue: status) ?? .unknown,
            species: species
        )
    }
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Domain Model | internal | `Sources/Domain/Models/` |
| Contract | internal | `Sources/Domain/Repositories/` |
| Implementation | internal | `Sources/Data/Repositories/` |
| DTO Mapping | internal | `Sources/Data/Repositories/` |
| Mock | internal | `Tests/Mocks/` |

---

## Checklist

### Remote Only Repository

- [ ] Create Domain model with Equatable and Sendable conformance
- [ ] Create Contract in Domain/Repositories/ with async throws methods
- [ ] Create Implementation injecting RemoteDataSource
- [ ] Add DTO to Domain mapping extension
- [ ] Create Mock in Tests/Mocks/ with call tracking
- [ ] Create tests verifying transformation and error propagation
- [ ] Run tests

### Local Only Repository

- [ ] Create Domain model with Equatable and Sendable conformance
- [ ] Create Contract in Domain/Repositories/ with async throws methods
- [ ] Create Implementation injecting MemoryDataSource
- [ ] Add DTO to Domain mapping extension
- [ ] Add Domain to DTO mapping extension (for saving)
- [ ] Create error enum for not found cases
- [ ] Create Mock in Tests/Mocks/ with call tracking
- [ ] Create tests verifying CRUD operations and error handling
- [ ] Run tests

### Local-First Repository (Both DataSources)

- [ ] Create Domain model with Equatable and Sendable conformance
- [ ] Create Contract in Domain/Repositories/ with async throws methods
- [ ] Create Implementation injecting both RemoteDataSource and MemoryDataSource
- [ ] Add DTO to Domain mapping extension
- [ ] Implement local-first policy (cache check → remote fetch → cache save)
- [ ] Create Mock in Tests/Mocks/ with call tracking
- [ ] Create tests for cache hit scenarios (no remote call)
- [ ] Create tests for cache miss scenarios (remote call + cache save)
- [ ] Create tests for error propagation
- [ ] Run tests
