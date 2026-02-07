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
│       └── Repositories/
│           └── {Name}Repository.swift            # Implementation
└── Tests/
    ├── Data/
    │   └── {Name}RepositoryTests.swift
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

Mapping extensions are defined in the **Repository file** as **private extensions**. This ensures:
- DTOs remain anemic (no knowledge of Domain models)
- Mapping is the Repository's responsibility (Anti-Corruption Layer)
- No leakage of transformation logic outside the Repository

```swift
// In {Name}Repository.swift

// MARK: - DTO to Domain Mapping

private extension {Name}DTO {
    func toDomain() -> {Name} {
        {Name}(id: id, name: name)
    }
}
```

**Why private?**
- Only the Repository should call `toDomain()`
- Encapsulates transformation logic
- Prevents other layers from depending on DTOs

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

### Error Mapping in Implementation

```swift
struct {Name}Repository: {Name}RepositoryContract {
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
            return .notFound(id: identifier)
        case .invalidURL, .invalidResponse, .statusCode:
            return .loadFailed
        }
    }
}
```

**Rules:**
- Use `throws({Feature}Error)` (typed throws) instead of generic `throws`
- Map `HTTPError` cases to domain-specific errors
- Include context in errors (e.g., `id`, `page`) for better debugging
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
    func get{Name}Detail(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name}
}
```

**Naming Convention:**
- Use `Detail` suffix for single-item methods: `get{Name}Detail`
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
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Domain Model | internal | `Sources/Domain/Models/` |
| Contract | internal | `Sources/Domain/Repositories/` |
| Implementation | internal | `Sources/Data/Repositories/` |
| DTO Mapping | **private** | `Sources/Data/Repositories/` (private extension) |
| Mock | internal | `Tests/Mocks/` |

---

## Checklists

### Remote Only Repository

- [ ] Create Domain model with Equatable conformance
- [ ] Create Domain error enum in Domain/Errors/ with typed throws
- [ ] Create Contract in Domain/Repositories/ using typed throws
- [ ] Create Implementation injecting RemoteDataSource
- [ ] Add DTO to Domain mapping extension
- [ ] Add HTTPError to Domain error mapping
- [ ] Create Mock in Tests/Mocks/
- [ ] Create tests verifying transformation and error mapping
- [ ] Add localized strings for error messages

### Local Only Repository

- [ ] Create Domain model with Equatable conformance
- [ ] Create Domain error enum in Domain/Errors/
- [ ] Create Contract in Domain/Repositories/ using typed throws
- [ ] Create Implementation injecting MemoryDataSource
- [ ] Add DTO to Domain mapping
- [ ] Add Domain to DTO mapping (for saving)
- [ ] Create Mock and tests

### Repository with CachePolicy (Both DataSources)

- [ ] Import `ChallengeCore` (provides `CachePolicy`)
- [ ] Create Domain model with Equatable conformance
- [ ] Create Domain error enum in Domain/Errors/ with typed throws
- [ ] Create Contract in Domain/Repositories/ with cachePolicy parameter
- [ ] Create Implementation injecting both DataSources
- [ ] Extract remote fetch helper methods
- [ ] Implement cache strategies (localFirst, remoteFirst, none)
- [ ] Add HTTPError to Domain error mapping
- [ ] Create tests for localFirst (cache hit → no remote call)
- [ ] Create tests for localFirst (cache miss → remote + save)
- [ ] Create tests for remoteFirst (always remote, cache fallback on error)
- [ ] Create tests for none (remote only, no cache interaction)
- [ ] Create tests for error mapping (404 → notFound, etc.)
- [ ] Add localized strings for error messages
