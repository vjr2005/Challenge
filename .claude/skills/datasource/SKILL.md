---
name: datasource
description: Creates DataSources for data access. Use when creating RemoteDataSource for REST APIs or GraphQL, MemoryDataSource for in-memory storage, LocalDataSource for UserDefaults persistence, or DTOs for API responses.
---

# Skill: DataSource

Guide for creating DataSources following the Repository pattern.

## Before Creating — Clarify Requirements

**CRITICAL:** Do NOT assume the API schema or operations. Ask the user before writing any code:

1. **Operations**: Which operations does the contract need and with what parameters? (e.g., paginated list, single item by ID, both, with filters, etc.)
2. **Entity fields**: What fields does the DTO need? For GraphQL, the user can provide the query directly — derive DTOs from its response shape. Otherwise, ask for the fields or API documentation. Never fetch external API docs on your own.

Only proceed to implementation after the user confirms these details.

---

## DataSource Types

| Type | Transport | Contract | Implementation | Error Mapper |
|------|-----------|----------|----------------|-------------|
| REST | HTTP | `: Sendable` | `struct` with `HTTPClientContract` | `HTTPErrorMapper` |
| GraphQL | HTTP/GraphQL | `: Sendable` | `struct` with `GraphQLClientContract` | `GraphQLErrorMapper` |
| Memory | In-memory | `: Actor` | `actor` with dictionary storage | — |
| UserDefaults | Local | `: Actor` | `actor` with `UserDefaults` | — |

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
│       │       └── {Name}UserDefaultsDataSource.swift    # Optional: UserDefaults
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

- Internal visibility, separate file from implementation
- Remote contracts: `: Sendable`. Local contracts (Memory, UserDefaults): `: Actor`
- Transport-agnostic: same contract for REST or GraphQL
- **DataSources only work with DTOs** — parameters and return types must be DTOs, never domain objects
- Remote: `async throws`. Local (Memory, UserDefaults): methods are actor-isolated (implicitly `async` from caller)

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

- [ ] Create Contract in `Local/` with `: Actor`
- [ ] Create `actor` Implementation in `Local/`
- [ ] Create `actor` Mock with setter methods and call tracking
- [ ] Create tests (use `await` for all mock reads/writes)

### LocalDataSource (UserDefaults)

- [ ] Create Contract in `Local/` with `: Actor`
- [ ] Create `actor` Implementation in `Local/` with `private let userDefaults`
- [ ] Create `actor` Mock with setter methods and call tracking
- [ ] Create `async` tests using custom `UserDefaults` suite (`nonisolated(unsafe)` on test property)
