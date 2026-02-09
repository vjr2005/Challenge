---
name: datasource
description: Creates DataSources for data access. Use when creating RemoteDataSource for REST APIs or GraphQL, MemoryDataSource for in-memory storage, LocalDataSource for UserDefaults persistence, or DTOs for API responses.
---

# Skill: DataSource

Guide for creating DataSources following the Repository pattern.

## DataSource Types

| Type | Transport | Implementation | Error Mapper |
|------|-----------|----------------|-------------|
| REST | HTTP | `struct` with `HTTPClientContract` | `HTTPErrorMapper` |
| GraphQL | HTTP/GraphQL | `struct` with `GraphQLClientContract` | `GraphQLErrorMapper` |
| Memory | In-memory | `actor` with dictionary storage | — |
| UserDefaults | Local | `struct` with `nonisolated(unsafe) let` | — |

## Templates

Each reference contains full templates: contract, implementation, DTO, mock, fixtures, and tests.

- **REST API**: See [remote-rest.md](references/remote-rest.md)
- **GraphQL API**: See [remote-graphql.md](references/remote-graphql.md)
- **Memory cache**: See [local-memory.md](references/local-memory.md)
- **UserDefaults**: See [local-userdefaults.md](references/local-userdefaults.md)

## File Structure

```
Features/{Feature}/
├── Sources/
│   └── Data/
│       ├── DataSources/
│       │   ├── Remote/
│       │   │   ├── {Name}RemoteDataSourceContract.swift
│       │   │   └── {Name}RESTDataSource.swift (or {Name}GraphQLDataSource.swift)
│       │   └── Local/
│       │       ├── {Name}LocalDataSourceContract.swift
│       │       ├── {Name}MemoryDataSource.swift
│       │       └── {Name}LocalDataSource.swift    # Optional: UserDefaults
│       └── DTOs/
│           └── {Name}DTO.swift
└── Tests/
    ├── Unit/Data/
    ├── Shared/Fixtures/
    │   ├── {name}.json
    │   └── {name}s_response.json
    └── Shared/Mocks/
```

---

## Key Principles

### Contracts

- Internal visibility, `Sendable`, separate file from implementation
- Transport-agnostic: same contract for REST or GraphQL
- **DataSources only work with DTOs** — parameters and return types must be DTOs, never domain objects
- Remote: `async throws`. Memory: `async` (no throws). UserDefaults: synchronous

### DTOs (Data Transfer Objects)

> *"A Data Transfer Object is one of those objects our mothers told us never to write. It's often little more than a bunch of fields and the getters and setters for them."*
> — Martin Fowler, [PoEAA](https://martinfowler.com/eaaCatalog/dataTransferObject.html)

DTOs are **intentionally anemic** — they exist purely to transfer data between systems.

**Rules:**
- `Decodable`, `Equatable`
- Internal visibility, properties match JSON keys
- **NO behavior** — only data (anemic by design)
- **NO `toDomain()` methods** — mapping belongs in the Repository
- REST IDs are `Int`, GraphQL IDs are `String`

### Error Mapping

DataSources catch transport errors and map them to `APIError`:
- REST: `HTTPError` → `APIError` via `HTTPErrorMapper`
- GraphQL: `GraphQLError` → `APIError` via `GraphQLErrorMapper`

Repositories and upper layers only see `APIError`, never transport-specific errors.

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Remote Contract | internal | `Sources/Data/DataSources/Remote/` |
| Remote Implementation | internal | `Sources/Data/DataSources/Remote/` |
| Local Contract | internal | `Sources/Data/DataSources/Local/` |
| Local Implementation | internal | `Sources/Data/DataSources/Local/` |
| DTO | internal | `Sources/Data/DTOs/` |
| Mocks | internal | `Tests/Shared/Mocks/` |

---

## Checklists

### RemoteDataSource (REST)

- [ ] Create DTO
- [ ] Create Contract in `Remote/` with `async throws`
- [ ] Create RESTDataSource in `Remote/` with `HTTPErrorMapper`
- [ ] Create Mock in `Tests/Shared/Mocks/`
- [ ] Create JSON fixtures in `Tests/Shared/Fixtures/`
- [ ] Create tests

### RemoteDataSource (GraphQL)

- [ ] Create DTO (IDs are `String`)
- [ ] Create Contract in `Remote/` with `async throws`
- [ ] Create GraphQLDataSource in `Remote/` with `GraphQLErrorMapper`
- [ ] Create Mock in `Tests/Shared/Mocks/`
- [ ] Create JSON fixtures in `Tests/Shared/Fixtures/`
- [ ] Create tests

### MemoryDataSource

- [ ] Create Contract in `Local/` with `async` methods
- [ ] Create `actor` Implementation in `Local/`
- [ ] Create `final class` Mock with `@unchecked Sendable` and call tracking
- [ ] Create tests

### LocalDataSource (UserDefaults)

- [ ] Create Contract in `Local/` with synchronous methods and `Sendable`
- [ ] Create `struct` Implementation in `Local/` with `nonisolated(unsafe) let userDefaults`
- [ ] Create `final class` Mock with `@unchecked Sendable` and call tracking
- [ ] Create tests using custom `UserDefaults` suite
