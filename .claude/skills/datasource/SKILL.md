---
name: datasource
description: Creates DataSources for data access. Use when creating RemoteDataSource for REST APIs, MemoryDataSource for in-memory storage, LocalDataSource for UserDefaults persistence, or DTOs for API responses.
---

# Skill: DataSource

Guide for creating DataSources following the Repository pattern.

- **RemoteDataSource**: Consumes REST APIs via HTTPClient
- **MemoryDataSource**: In-memory storage using actors for thread safety
- **LocalDataSource**: Persistent local storage using UserDefaults (struct, synchronous)

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

### DTO (Data Transfer Object)

> *"A Data Transfer Object is one of those objects our mothers told us never to write. It's often little more than a bunch of fields and the getters and setters for them."*
> — Martin Fowler, [PoEAA](https://martinfowler.com/eaaCatalog/dataTransferObject.html)

DTOs are **intentionally anemic** - they exist purely to transfer data between systems.

```swift
struct {Name}DTO: Decodable, Equatable, Sendable {
    let id: Int
    let name: String
}
```

**Rules:**
- `Decodable`, `Equatable`, `Sendable`
- Internal visibility
- Properties match JSON keys
- **NO behavior** - only data (anemic by design)
- **NO `toDomain()` methods** - mapping belongs in the Repository

**Why anemic?**
- DTOs represent the structure of an **external system** (the API)
- If we add logic, it couples to the external API structure
- The Repository is responsible for translating DTOs to Domain models

---

## MemoryDataSource Pattern

### Contract

```swift
protocol {Name}MemoryDataSourceContract: Sendable {
    // MARK: - Single Item (Detail)
    func get{Name}Detail(identifier: Int) async -> {Name}DTO?
    func save{Name}Detail(_ item: {Name}DTO) async
    func delete{Name}Detail(identifier: Int) async

    // MARK: - Paginated Results (optional)
    func getPage(_ page: Int) async -> {Name}sResponseDTO?
    func savePage(_ response: {Name}sResponseDTO, page: Int) async
}
```

**Rules:**
- `async` (no throws), return optional for get
- Use `Detail` suffix for single-item methods to distinguish from list operations
- `identifier` parameter name (not `id`) for consistency

### Implementation (Actor)

```swift
actor {Name}MemoryDataSource: {Name}MemoryDataSourceContract {
    private var items: [Int: {Name}DTO] = [:]
    private var pages: [Int: {Name}sResponseDTO] = [:]

    // MARK: - Single Item

    func get{Name}Detail(identifier: Int) -> {Name}DTO? { items[identifier] }
    func save{Name}Detail(_ item: {Name}DTO) { items[item.id] = item }
    func delete{Name}Detail(identifier: Int) { items.removeValue(forKey: identifier) }

    // MARK: - Paginated Results

    func getPage(_ page: Int) -> {Name}sResponseDTO? { pages[page] }
    func savePage(_ response: {Name}sResponseDTO, page: Int) { pages[page] = response }
}
```

**Rules:** Use `actor`, dictionary storage, no `async` in signatures

---

## LocalDataSource Pattern

For persistent local storage using `UserDefaults` (e.g., recent searches, user preferences).

### Contract

```swift
protocol {Name}LocalDataSourceContract: Sendable {
	func getItems() -> [String]
	func saveItem(_ item: String)
	func deleteItem(_ item: String)
}
```

**Rules:** Internal visibility, `Sendable`, **synchronous** (no `async`)

### Implementation

```swift
struct {Name}LocalDataSource: {Name}LocalDataSourceContract {
	private nonisolated(unsafe) let userDefaults: UserDefaults
	private let key = "{storageKey}"

	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}

	func getItems() -> [String] {
		userDefaults.stringArray(forKey: key) ?? []
	}

	func saveItem(_ item: String) {
		var items = getItems()
		items.insert(item, at: 0)
		userDefaults.set(items, forKey: key)
	}

	func deleteItem(_ item: String) {
		var items = getItems()
		items.removeAll { $0 == item }
		userDefaults.set(items, forKey: key)
	}
}
```

**Rules:**
- Use `struct` (not `actor`) since `UserDefaults` is thread-safe
- Use `nonisolated(unsafe) let` for `UserDefaults` to satisfy `Sendable`
- Synchronous methods (no `async`)
- Always provide a default `UserDefaults` parameter for testability

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

### LocalDataSource

- [ ] Create Contract with synchronous methods and `Sendable`
- [ ] Create `struct` Implementation with `nonisolated(unsafe) let userDefaults`
- [ ] Create `final class` Mock with `@unchecked Sendable` and call tracking
- [ ] Create tests using custom `UserDefaults` suite
