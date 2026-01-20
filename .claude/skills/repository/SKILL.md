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
Libraries/Features/{Feature}/
├── Sources/
│   ├── Domain/
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

### Domain Model

```swift
struct {Name}: Equatable {
    let id: Int
    let name: String
}
```

**Rules:**
- Located in `Domain/Models/`
- **Internal visibility**
- Conform to `Equatable`
- Use `let` properties (immutable)

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

```swift
extension {Name}DTO {
    func toDomain() -> {Name} {
        {Name}(id: id, name: name)
    }
}
```

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

## Local-First Policy

When using both DataSources, follow this order:

1. Check local cache first
2. If found in cache, return cached data
3. If not found, fetch from remote
4. Save to local cache
5. Return the data

```swift
func get{Name}(id: Int) async throws -> {Name} {
    if let cached = await memoryDataSource.get{Name}(id: id) {
        return cached.toDomain()
    }
    let dto = try await remoteDataSource.fetch{Name}(id: id)
    await memoryDataSource.save{Name}(dto)
    return dto.toDomain()
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

## Checklists

### Remote Only Repository

- [ ] Create Domain model with Equatable conformance
- [ ] Create Contract in Domain/Repositories/
- [ ] Create Implementation injecting RemoteDataSource
- [ ] Add DTO to Domain mapping extension
- [ ] Create Mock in Tests/Mocks/
- [ ] Create tests verifying transformation and error propagation

### Local Only Repository

- [ ] Create Domain model with Equatable conformance
- [ ] Create Contract in Domain/Repositories/
- [ ] Create Implementation injecting MemoryDataSource
- [ ] Add DTO to Domain mapping
- [ ] Add Domain to DTO mapping (for saving)
- [ ] Create error enum for not found cases
- [ ] Create Mock and tests

### Local-First Repository

- [ ] Create Domain model with Equatable conformance
- [ ] Create Contract in Domain/Repositories/
- [ ] Create Implementation injecting both DataSources
- [ ] Implement local-first policy
- [ ] Create tests for cache hit (no remote call)
- [ ] Create tests for cache miss (remote call + cache save)
- [ ] Create tests for error propagation
