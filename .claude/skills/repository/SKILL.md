---
name: repository
description: Creates Repositories that abstract data access. Use when creating repositories, transforming DTOs to domain models, or implementing local-first caching. Supports remote-only, local-only, and cached (remote + local) repositories with CachePolicy.
---

# Skill: Repository

Guide for creating Repositories that abstract data access following Clean Architecture.

## References

Each reference contains full templates: contract, implementation, mock, and tests.

- **Remote only**: See [references/remote-only.md](references/remote-only.md)
- **Local only**: See [references/local-only.md](references/local-only.md)
- **Cache — localFirst only**: See [references/cache-local-first.md](references/cache-local-first.md)
- **Cache — remoteFirst only**: See [references/cache-remote-first.md](references/cache-remote-first.md)
- **Cache — noCache only**: See [references/cache-no-cache.md](references/cache-no-cache.md)
- **Cache — All configurable (recommended)**: See [references/cache-all.md](references/cache-all.md)

---

## Scope & Boundaries

> **Important:** The `/repository` skill is responsible **only** for Domain and Data layer files (models, errors, contracts, mappers, repositories, mocks, stubs, tests). It does **NOT** modify Feature entry points (`{Feature}Feature.swift`), Containers (`{Feature}Container.swift`), AppContainer, or Tuist modules. Any changes to these files must be delegated to the `/feature` skill, which owns the wiring of dependencies into the feature.

---

## Workflow

### Step 1 — Identify Existing DataSources

Before creating a Repository, scan the feature's `Sources/Data/DataSources/` directory to discover what already exists.

- **DataSources found?** → Go to Step 2
- **No DataSources found?** → Ask the user which DataSource to create first, then invoke the `/datasource` skill. Return here after completion.

### Step 2 — Select Target DataSource

Present the discovered DataSources to the user and ask:

> "Which DataSource(s) should this Repository use?"

Possible combinations:

| Scenario | DataSources | Next step |
|----------|-------------|-----------|
| Remote only | `RemoteDataSource` only | → Step 3a |
| Local only (memory) | `MemoryDataSource` only | → Step 3b |
| Local only (persistent) | `LocalDataSource` (UserDefaults) only | → Step 3b |
| Both (cached) | `RemoteDataSource` + `MemoryDataSource` | → Step 3c |

If the user wants a cached repository but **no local DataSource exists**:

> "There is no local DataSource for caching. Do you want to create one using the `/datasource` skill?"

If yes → invoke `/datasource` to create the Memory DataSource, then return to Step 3c.

### Step 3a — Remote Only Repository

Implement using [references/remote-only.md](references/remote-only.md).

Checklist:
- [ ] Domain model (`Equatable`, `let` properties, in `Domain/Models/`)
- [ ] Domain error enum in `Domain/Errors/` (typed throws, `LocalizedError`, custom `Equatable`, `CustomDebugStringConvertible`)
- [ ] Contract in `Domain/Repositories/` (typed throws, `Sendable`)
- [ ] Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Error Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Implementation in `Data/Repositories/` (injects RemoteDataSource, uses Mapper + Error Mapper)
- [ ] Mock in `Tests/Mocks/`
- [ ] Mapper tests, Error Mapper tests, Repository tests
- [ ] Localized strings for error messages

### Step 3b — Local Only Repository

Implement using [references/local-only.md](references/local-only.md).

Checklist:
- [ ] Domain model (`Equatable`, `let` properties, in `Domain/Models/`)
- [ ] Domain error enum in `Domain/Errors/`
- [ ] Contract in `Domain/Repositories/` (typed throws, `Sendable`)
- [ ] Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Implementation in `Data/Repositories/` (injects LocalDataSource, uses Mapper)
- [ ] Domain-to-DTO mapping (for saving)
- [ ] Mock in `Tests/Mocks/`
- [ ] Tests

### Step 3c — Cached Repository (Remote + Local)

**Ask the user which cache policy to apply:**

> "Which cache policy should this Repository use?"
>
> - **localFirst** — Cache first, remote if cache miss. Saves remote result to cache.
> - **remoteFirst** — Remote first, cache as fallback on error. Saves remote result to cache.
> - **noCache** — Remote only, no cache interaction.
> - **All (configurable)** — Accept `CachePolicy` parameter, implement all three strategies.

For most repositories, **"All (configurable)"** is recommended — callers decide the policy per request.

| User choice | Reference to use |
|-------------|-----------------|
| localFirst | [references/cache-local-first.md](references/cache-local-first.md) |
| remoteFirst | [references/cache-remote-first.md](references/cache-remote-first.md) |
| noCache | [references/cache-no-cache.md](references/cache-no-cache.md) |
| All (configurable) | [references/cache-all.md](references/cache-all.md) |

Checklist (for All configurable — adapt for single-policy variants):
- [ ] Import `ChallengeCore` (provides `CachePolicy` and `MapperContract`)
- [ ] Domain model (`Equatable`, `let` properties, in `Domain/Models/`)
- [ ] Domain error enum in `Domain/Errors/` (typed throws, `LocalizedError`, custom `Equatable`, `CustomDebugStringConvertible`)
- [ ] Contract in `Domain/Repositories/` with `cachePolicy: CachePolicy` parameter
- [ ] Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Error Mapper in `Data/Mappers/` (`MapperContract`)
- [ ] Implementation in `Data/Repositories/` (injects both DataSources, uses Mapper + Error Mapper)
- [ ] Extract `fetchFromRemote` helper (avoids duplication)
- [ ] Implement cache strategies
- [ ] Mock in `Tests/Mocks/` (tracks `cachePolicy`)
- [ ] Mapper tests, Error Mapper tests
- [ ] Tests for each cache strategy
- [ ] Tests for error handling
- [ ] Localized strings for error messages

---

## File Structure

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
│       ├── DataSources/                          # See /datasource skill
│       ├── DTOs/                                 # See /datasource skill
│       ├── Mappers/
│       │   ├── {Name}Mapper.swift                # DTO → Domain mapping
│       │   └── {Name}ErrorMapper.swift           # APIError → Domain error
│       └── Repositories/
│           └── {Name}Repository.swift            # Implementation
└── Tests/
    ├── Data/
    │   ├── {Name}RepositoryTests.swift
    │   └── Mappers/
    │       └── {Name}ErrorMapperTests.swift
    ├── Domain/
    │   └── Errors/
    │       └── {Feature}ErrorTests.swift
    └── Mocks/
        └── {Name}RepositoryMock.swift
```

---

## Patterns

### Domain Model (Rich, not Anemic)

Domain models **should have behavior** intrinsic to the concept they represent (unlike DTOs, which are intentionally anemic):

```swift
struct {Name}: Equatable {
    let id: Int
    let name: String
    let items: [Item]

    static func empty() -> {Name} {
        {Name}(id: 0, name: "", items: [])
    }

    var totalValue: Decimal {
        items.reduce(0) { $0 + $1.price }
    }
}
```

**Rules:** `Domain/Models/`, internal visibility, `Equatable`, `let` properties, may include factory methods / computed properties / business rules. No persistence, presentation, or serialization logic.

### Contract (Protocol)

```swift
import ChallengeCore

protocol {Name}RepositoryContract: Sendable {
    func get{Name}(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name}
}
```

**Rules:** `Domain/Repositories/`, `Contract` suffix, internal, `Sendable`, return Domain models (not DTOs), typed throws. Include `cachePolicy: CachePolicy` for cached repos.

**Naming:** `get{Name}` (singular), `get{Name}sPage` (paginated list), `search{Name}sPage` (search). Separate contracts per ISP when concerns differ.

### DTO → Domain Mapping

```swift
import ChallengeCore

struct {Name}Mapper: MapperContract {
    func map(_ input: {Name}DTO) -> {Name} {
        {Name}(id: input.id, name: input.name)
    }
}
```

Pure stateless structs, `MapperContract` from `ChallengeCore`. Used as concrete types in repositories (not injected). Composable: mappers can delegate to other mappers.

### Error Mapping

```swift
import ChallengeCore
import ChallengeNetworking

struct {Name}ErrorMapperInput {
    let error: any Error
    let identifier: Int
}

struct {Name}ErrorMapper: MapperContract {
    func map(_ input: {Name}ErrorMapperInput) -> {Feature}Error {
        guard let apiError = input.error as? APIError else {
            return .loadFailed(description: String(describing: input.error))
        }
        return switch apiError {
        case .notFound:
            .notFound(identifier: input.identifier)
        case .invalidRequest, .invalidResponse, .serverError, .decodingFailed:
            .loadFailed(description: String(describing: apiError))
        }
    }
}
```

### Domain Error

```swift
public enum {Feature}Error: Error, Equatable, LocalizedError {
    case loadFailed(description: String = "")
    case notFound(identifier: Int)

    public static func == (lhs: {Feature}Error, rhs: {Feature}Error) -> Bool {
        switch (lhs, rhs) {
        case (.loadFailed, .loadFailed): true
        case let (.notFound(lhsId), .notFound(rhsId)): lhsId == rhsId
        default: false
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
        case .loadFailed(let description): description
        case .notFound(let identifier): "notFound(identifier: \(identifier))"
        }
    }
}
```

**Rules:** Public, `Error` + `Equatable` + `LocalizedError`, custom `==` ignores `description`, `CustomDebugStringConvertible` for tracker, localized strings from Resources.

---

## CachePolicy

Defined in `ChallengeCore`, shared across features:

```swift
public enum CachePolicy {
    case localFirst   // Cache → Remote (if miss) → Save to cache
    case remoteFirst  // Remote → Save to cache → Cache (if error)
    case noCache      // Remote only, no cache interaction
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Domain Model | internal | `Sources/Domain/Models/` |
| Domain Error | **public** | `Sources/Domain/Errors/` |
| Contract | internal | `Sources/Domain/Repositories/` |
| Implementation | internal | `Sources/Data/Repositories/` |
| Mapper | internal | `Sources/Data/Mappers/` |
| Error Mapper | internal | `Sources/Data/Mappers/` |
| Mock | internal | `Tests/Mocks/` |
