---
name: datasource
description: Creates DataSources for data access. Use when creating RemoteDataSource for REST APIs, MemoryDataSource for in-memory storage, or DTOs for API responses.
---

# Skill: DataSource

Guide for creating DataSources following the Repository pattern.

- **RemoteDataSource**: Consumes REST APIs via HTTPClient
- **MemoryDataSource**: In-memory storage using actors for thread safety

## When to use this skill

- Create a new RemoteDataSource to consume an API
- Create a new MemoryDataSource for in-memory caching
- Create DTOs for API responses

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## File structure

```
Features/{Feature}/
├── Sources/
│   └── Data/
│       ├── DataSources/
│       │   ├── {Name}RemoteDataSource.swift
│       │   └── {Name}MemoryDataSource.swift
│       └── DTOs/
│           └── {Name}DTO.swift
└── Tests/
    ├── Data/
    ├── Fixtures/
    │   ├── {name}.json
    │   └── {name}_list.json
    └── Mocks/
```

---

## RemoteDataSource Pattern

### Contract

```swift
protocol {Name}RemoteDataSourceContract: Sendable {
    func fetch{Name}(id: Int) async throws -> {Name}DTO
}
```

**Rules:** Internal visibility, `Sendable`, `async throws`, return DTOs

### Implementation

```swift
struct {Name}RemoteDataSource: {Name}RemoteDataSourceContract {
    private let httpClient: HTTPClientContract

    init(httpClient: HTTPClientContract) {
        self.httpClient = httpClient
    }

    func fetch{Name}(id: Int) async throws -> {Name}DTO {
        let endpoint = Endpoint(path: "/{resource}/\(id)")
        return try await httpClient.request(endpoint)
    }
}
```

### DTO

```swift
nonisolated struct {Name}DTO: Decodable, Equatable {
    let id: Int
    let name: String
}
```

**Rules:**
- `nonisolated` for actor usage
- `Decodable`, `Equatable`
- Internal visibility
- Properties match JSON keys

---

## MemoryDataSource Pattern

### Contract

```swift
protocol {Name}MemoryDataSourceContract: Sendable {
    func get{Name}(id: Int) async -> {Name}DTO?
    func save{Name}(_ item: {Name}DTO) async
    func delete{Name}(id: Int) async
}
```

**Rules:** `async` (no throws), return optional for get

### Implementation (Actor)

```swift
actor {Name}MemoryDataSource: {Name}MemoryDataSourceContract {
    private var storage: [Int: {Name}DTO] = [:]

    func get{Name}(id: Int) -> {Name}DTO? { storage[id] }
    func save{Name}(_ item: {Name}DTO) { storage[item.id] = item }
    func delete{Name}(id: Int) { storage.removeValue(forKey: id) }
}
```

**Rules:** Use `actor`, dictionary storage, no `async` in signatures

---

## JSON Fixtures

Tests use JSON files replicating real API responses.

**Location:** `Tests/Fixtures/`
**Naming:** snake_case (`character.json`, `character_list.json`)

**Loading in tests:**

Each test file defines a private extension to wrap `Bundle.module` access:

```swift
private extension {Name}DataSourceTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }

    func loadJSONData(_ filename: String) throws -> Data {
        try Bundle.module.loadJSONData(filename)
    }
}
```

Import `{AppName}CoreMocks` for `Bundle+JSON` helper.

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Contract | internal | `Sources/Data/DataSources/` |
| Implementation | internal | `Sources/Data/DataSources/` |
| DTO | internal | `Sources/Data/DTOs/` |
| Mocks | internal | `Tests/Mocks/` |

---

## Checklists

### RemoteDataSource

- [ ] Create DTO with `nonisolated`
- [ ] Create Contract with `async throws`
- [ ] Create Implementation injecting HTTPClientContract
- [ ] Create Mock in `Tests/Mocks/`
- [ ] Create JSON fixtures in `Tests/Fixtures/`
- [ ] Create tests using JSON fixtures

### MemoryDataSource

- [ ] Create Contract with `async` methods
- [ ] Create `actor` Implementation
- [ ] Create `final class` Mock with `@unchecked Sendable` and call tracking
- [ ] Create tests
