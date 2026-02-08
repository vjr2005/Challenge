---
name: repository
description: Creates Repositories that abstract data access. Use when creating repositories, transforming DTOs to domain models, or implementing local-first caching.
---

# Skill: Repository

Guide for creating Repositories that abstract data access following Clean Architecture.

## When to use this skill

- Create a new Repository to abstract data sources
- Transform DTOs to Domain models
- Provide a clean API for Use Cases
- Implement caching with local-first policy

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## File structure

```
Features/{Feature}/
├── Sources/
│   ├── Domain/
│   │   ├── Errors/
│   │   │   └── {Feature}Error.swift              # Domain error (typed throws)
│   │   ├── Models/
│   │   │   └── {Name}.swift                      # Domain model
│   │   └── Repositories/
│   │       └── {Name}RepositoryContract.swift    # Contract (protocol)
│   └── Data/
│       ├── DataSources/
│       │   ├── {Name}RemoteDataSource.swift      # See /datasource skill
│       │   └── {Name}MemoryDataSource.swift      # See /datasource skill
│       ├── DTOs/
│       │   └── {Name}DTO.swift                   # See /datasource skill
│       ├── Mappers/
│       │   ├── {Name}Mapper.swift                # DTO to Domain mapping
│       │   └── {Name}ErrorMapper.swift           # HTTPError to Domain error mapping
│       └── Repositories/
│           └── {Name}Repository.swift            # Implementation
└── Tests/
    ├── Data/
    │   ├── {Name}RepositoryTests.swift
    │   └── Mappers/
    │       └── {Name}ErrorMapperTests.swift
    ├── Domain/
    │   └── Errors/
    │       └── {Feature}ErrorTests.swift         # Error tests
    └── Mocks/
        └── {Name}RepositoryMock.swift
```

## Repository Scenarios

| Scenario | DataSources | Use case |
|----------|-------------|----------|
| Remote only | `RemoteDataSource` | Simple API consumption |
| Local only | `MemoryDataSource` | Offline-first, local state |
| Both (local-first) | `RemoteDataSource` + `MemoryDataSource` | Caching with remote fallback |

---

## Patterns

### Domain Model (Rich, not Anemic)

> *"The basic symptom of an Anemic Domain Model is that at first blush it looks like the real thing... but there is hardly any behavior on these objects, making them little more than bags of getters and setters."*
> — Martin Fowler, [Anemic Domain Model](https://martinfowler.com/bliki/AnemicDomainModel.html)

Domain models **should have behavior** that is intrinsic to the concept they represent. Unlike DTOs (which are intentionally anemic), domain models can include:

- Factory methods (e.g., `.empty()`)
- Computed properties
- Business rules and validations

```swift
struct {Name}: Equatable {
    let id: Int
    let name: String
    let items: [Item]

    // ✓ Factory method - valid domain concept
    static func empty() -> {Name} {
        {Name}(id: 0, name: "", items: [])
    }

    // ✓ Computed property - business logic
    var totalValue: Decimal {
        items.reduce(0) { $0 + $1.price }
    }

    // ✓ Business rule
    func canBeProcessed() -> Bool {
        !items.isEmpty && totalValue > 0
    }
}
```

**What belongs in Domain Model:**
- Factory methods for valid domain states
- Computed properties derived from its data
- Business rules intrinsic to the concept

**What does NOT belong in Domain Model:**
- Persistence logic (`save()`, `fetch()`) → Repository
- Presentation logic (`displayName()`) → ViewModel
- Serialization (`toJSON()`) → DTO

**Rules:**
- Located in `Domain/Models/`
- **Internal visibility**
- Conform to `Equatable`
- Use `let` properties (immutable)
- **May include behavior** that is intrinsic to the domain concept

### Contract (Protocol)

```swift
protocol {Name}RepositoryContract: Sendable {
    func get{Name}(id: Int) async throws -> {Name}
    func getAll{Name}s() async throws -> [{Name}]
}
```

**Rules:**
- Located in `Domain/Repositories/`
- `Contract` suffix
- **Internal visibility**
- Conform to `Sendable`
- **Return Domain models, NOT DTOs**

### DTO to Domain Mapping

Mapping logic lives in dedicated **Mapper types** that conform to `MapperContract` (from `ChallengeCore`). Each Mapper is a pure, stateless struct that transforms DTOs into Domain models. Repositories use Mappers as concrete types (not injected via protocol), since they are deterministic and don't need mocking.

```swift
// Libraries/Core/Sources/Data/MapperContract.swift
public protocol MapperContract<Input, Output>: Sendable {
    associatedtype Input
    associatedtype Output
    func map(_ input: Input) -> Output
}
```

```swift
// In Sources/Data/Mappers/{Name}Mapper.swift
import ChallengeCore

struct {Name}Mapper: MapperContract {
    func map(_ input: {Name}DTO) -> {Name} {
        {Name}(id: input.id, name: input.name)
    }
}
```

```swift
// In {Name}Repository.swift
struct {Name}Repository: {Name}RepositoryContract {
    private let mapper = {Name}Mapper()

    func get{Name}(identifier: Int) async throws -> {Name} {
        let dto = try await remoteDataSource.fetch{Name}(identifier: identifier)
        return mapper.map(dto)
    }
}
```

**Why Mapper types?**
- Single Responsibility: Repositories handle data access, Mappers handle transformation
- Independently testable without data source mocks
- Composable: Mappers can delegate to other Mappers (e.g., `CharacterMapper` uses `LocationMapper`)
- DTOs remain anemic (no knowledge of Domain models)

### Mock

```swift
final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
    var result: Result<{Name}, Error> = .failure(NotConfiguredError.notConfigured)
    private(set) var getCallCount = 0
    private(set) var lastRequestedId: Int?

    func get{Name}(id: Int) async throws -> {Name} {
        getCallCount += 1
        lastRequestedId = id
        return try result.get()
    }
}
```

**Rules:**
- Located in `Tests/Mocks/`
- Requires `@testable import`
- `@unchecked Sendable` for mutable state

---

## Error Handling

Repositories transform data layer errors (e.g., `HTTPError`) into domain-specific errors using **typed throws**.

### Domain Error

```
Features/{Feature}/
└── Sources/
    └── Domain/
        └── Errors/
            └── {Feature}Error.swift
```

```swift
public enum {Feature}Error: Error, Equatable, Sendable, LocalizedError {
    case loadFailed
    case notFound(id: Int)
    case invalidPage(page: Int)

    public var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "{feature}Error.loadFailed".localized()
        case .notFound(let id):
            return "{feature}Error.notFound %lld".localized(id)
        case .invalidPage(let page):
            return "{feature}Error.invalidPage %lld".localized(page)
        }
    }
}
```

**Rules:**
- Located in `Domain/Errors/`
- **Public visibility** (used by presentation layer)
- Conform to `Error`, `Equatable`, `Sendable`, `LocalizedError`
- Use localized strings from Resources module

### Typed Throws in Contract

```swift
protocol {Name}RepositoryContract: Sendable {
    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name}
}
```

### Error Mapping with Error Mappers

Error mapping logic lives in dedicated **Error Mapper types** that conform to `MapperContract`, following the same pattern as data mappers. This keeps repositories focused on data access orchestration while error transformation is independently testable.

```swift
// In Sources/Data/Mappers/{Name}ErrorMapper.swift
import ChallengeCore
import ChallengeNetworking

struct {Name}ErrorMapperInput {
    let error: any Error
    let identifier: Int
}

struct {Name}ErrorMapper: MapperContract {
    func map(_ input: {Name}ErrorMapperInput) -> {Feature}Error {
        guard let httpError = input.error as? HTTPError else {
            return .loadFailed
        }
        return switch httpError {
        case .statusCode(404, _):
            .notFound(identifier: input.identifier)
        case .invalidURL, .invalidResponse, .statusCode:
            .loadFailed
        }
    }
}
```

```swift
// In {Name}Repository.swift
struct {Name}Repository: {Name}RepositoryContract {
    private let errorMapper = {Name}ErrorMapper()

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

**Why Error Mapper types?**
- Single Responsibility: Repositories handle data access, Error Mappers handle error transformation
- Independently testable without data source mocks
- Consistent with data Mapper pattern (`MapperContract`)

**Rules:**
- Use `throws({Feature}Error)` (typed throws) instead of generic `throws`
- Map `HTTPError` cases to domain-specific errors via Error Mapper
- Include context in errors (e.g., `identifier`, `page`) for better debugging
- Fallback to generic error (`.loadFailed`) for unexpected cases

---

## CachePolicy

Use `CachePolicy` enum (from `ChallengeCore`) to control cache behavior:

```swift
// Libraries/Core/Sources/Data/CachePolicy.swift
public enum CachePolicy: Sendable {
    case localFirst   // Cache first, remote if not found (default)
    case remoteFirst  // Remote first, cache as fallback on error
    case noCache      // Only remote, no cache interaction
}
```

> **Note:** `CachePolicy` is defined in `ChallengeCore` so it can be reused across features. Import `ChallengeCore` in any file that references it.

### Contract with CachePolicy

```swift
import ChallengeCore

protocol {Name}RepositoryContract: Sendable {
    func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name}
}
```

**Naming Convention:**
- Use singular for single-item methods: `get{Name}`
- Use `Page` suffix for list methods: `get{Name}sPage`, `search{Name}sPage`
- This avoids confusion between `getCharacter` and `getCharactersPage`

### Cache Strategies

| Policy | Behavior |
|--------|----------|
| `.localFirst` | Cache → Remote (if miss) → Save to cache |
| `.remoteFirst` | Remote → Save to cache → Cache (if error) |
| `.noCache` | Remote only, no cache interaction |

### Implementation Pattern

Extract remote fetching into a helper to avoid code duplication:

```swift
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
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Domain Model | internal | `Sources/Domain/Models/` |
| Contract | internal | `Sources/Domain/Repositories/` |
| Implementation | internal | `Sources/Data/Repositories/` |
| Mapper | internal | `Sources/Data/Mappers/` |
| Mock | internal | `Tests/Mocks/` |

---

## Checklists

### Remote Only Repository

- [ ] Create Domain model with Equatable conformance
- [ ] Create Domain error enum in Domain/Errors/ with typed throws
- [ ] Create Contract in Domain/Repositories/ using typed throws
- [ ] Create Mapper in Data/Mappers/ conforming to `MapperContract`
- [ ] Create Error Mapper in Data/Mappers/ conforming to `MapperContract`
- [ ] Create Implementation injecting RemoteDataSource, using Mapper and Error Mapper
- [ ] Create Mock in Tests/Mocks/
- [ ] Create Mapper tests verifying transformation
- [ ] Create Error Mapper tests verifying error transformation
- [ ] Create Repository tests verifying data access and generic error handling
- [ ] Add localized strings for error messages

### Local Only Repository

- [ ] Create Domain model with Equatable conformance
- [ ] Create Domain error enum in Domain/Errors/
- [ ] Create Contract in Domain/Repositories/ using typed throws
- [ ] Create Mapper in Data/Mappers/ conforming to `MapperContract`
- [ ] Create Implementation injecting MemoryDataSource, using Mapper
- [ ] Add Domain to DTO mapping (for saving)
- [ ] Create Mock and tests

### Repository with CachePolicy (Both DataSources)

- [ ] Import `ChallengeCore` (provides `CachePolicy` and `MapperContract`)
- [ ] Create Domain model with Equatable conformance
- [ ] Create Domain error enum in Domain/Errors/ with typed throws
- [ ] Create Contract in Domain/Repositories/ with cachePolicy parameter
- [ ] Create Mapper in Data/Mappers/ conforming to `MapperContract`
- [ ] Create Error Mapper in Data/Mappers/ conforming to `MapperContract`
- [ ] Create Implementation injecting both DataSources, using Mapper and Error Mapper
- [ ] Extract remote fetch helper methods
- [ ] Implement cache strategies (localFirst, remoteFirst, none)
- [ ] Create Mapper tests verifying transformation
- [ ] Create Error Mapper tests verifying error transformation
- [ ] Create tests for localFirst (cache hit → no remote call)
- [ ] Create tests for localFirst (cache miss → remote + save)
- [ ] Create tests for remoteFirst (always remote, cache fallback on error)
- [ ] Create tests for none (remote only, no cache interaction)
- [ ] Create tests for generic error handling in repository
- [ ] Add localized strings for error messages
