# Skill: Repository

Guide for creating Repositories that abstract data access following Clean Architecture.

## When to use this skill

- Create a new Repository to abstract data sources
- Transform DTOs to Domain models
- Provide a clean API for Use Cases

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
│       │   └── {Name}RemoteDataSource.swift      # DataSource (see /datasource skill)
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

## Repository Pattern

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
- Conform to `Equatable` and `Sendable`
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

### 3. Implementation - Data Layer

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

**Rules:**
- Located in `Data/Repositories/`
- **Internal visibility** (not public)
- Inject DataSource via protocol (not concrete type)
- Transform DTOs to Domain models using `toDomain()` extension

### 4. DTO to Domain Mapping

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

### 5. Mock (in Tests/Mocks/)

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

## Testing

### Repository Test

```swift
import Foundation
import Testing

@testable import Challenge{FeatureName}

struct {Name}RepositoryTests {
    @Test
    func getsModelFromDataSource() async throws {
        // Given
        let expectedDTO = {Name}DTO(id: 1, name: "Test")
        let dataSource = {Name}RemoteDataSourceMock()
        dataSource.result = .success(expectedDTO)
        let sut = {Name}Repository(remoteDataSource: dataSource)

        // When
        let result = try await sut.get{Name}(id: 1)

        // Then
        #expect(result.id == expectedDTO.id)
        #expect(result.name == expectedDTO.name)
        #expect(dataSource.fetchCallCount == 1)
        #expect(dataSource.lastFetchedId == 1)
    }

    @Test
    func transformsDTOToDomainModel() async throws {
        // Given
        let dto = {Name}DTO(id: 42, name: "Domain Test")
        let dataSource = {Name}RemoteDataSourceMock()
        dataSource.result = .success(dto)
        let sut = {Name}Repository(remoteDataSource: dataSource)

        // When
        let result = try await sut.get{Name}(id: 42)

        // Then
        #expect(result == {Name}(id: 42, name: "Domain Test"))
    }

    @Test
    func propagatesDataSourceError() async throws {
        // Given
        let dataSource = {Name}RemoteDataSourceMock()
        dataSource.result = .failure(TestError.network)
        let sut = {Name}Repository(remoteDataSource: dataSource)

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

## Complete Example: Character

### Domain Model

```swift
// Sources/Domain/Models/Character.swift
struct Character: Equatable, Sendable {
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

### Implementation

```swift
// Sources/Data/Repositories/CharacterRepository.swift
struct CharacterRepository: CharacterRepositoryContract {
    private let remoteDataSource: CharacterRemoteDataSourceContract

    init(remoteDataSource: CharacterRemoteDataSourceContract) {
        self.remoteDataSource = remoteDataSource
    }

    func getCharacter(id: Int) async throws -> Character {
        let dto = try await remoteDataSource.fetchCharacter(id: id)
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

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Domain Model | internal | `Sources/Domain/Models/` |
| Contract | internal | `Sources/Domain/Repositories/` |
| Implementation | internal | `Sources/Data/Repositories/` |
| DTO Mapping | internal | `Sources/Data/Repositories/` |
| Mock | internal | `Tests/Mocks/` |

## Checklist

- [ ] Create Domain model with Equatable and Sendable conformance
- [ ] Create Contract in Domain/Repositories/ with async throws methods
- [ ] Create Implementation in Data/Repositories/ injecting DataSource
- [ ] Add DTO to Domain mapping extension
- [ ] Create Mock in Tests/Mocks/ with call tracking
- [ ] Create tests verifying transformation and error propagation
- [ ] Run tests
