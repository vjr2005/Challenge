---
name: datasource
description: Creates DataSources for data access. Use when creating RemoteDataSource for REST APIs, MemoryDataSource for in-memory storage, or DTOs for API responses.
---

# Skill: DataSource

Guide for creating DataSources following the Repository pattern. Supports two types:

- **RemoteDataSource**: Consumes REST APIs via HTTPClient
- **MemoryDataSource**: In-memory storage using actors for thread safety

## When to use this skill

- Create a new RemoteDataSource to consume an API
- Create a new MemoryDataSource for in-memory caching or storage
- Add endpoints to an existing DataSource
- Create DTOs for API responses

## File structure

```
Libraries/Features/{FeatureName}/
├── Sources/
│   └── Data/
│       ├── DataSources/
│       │   ├── {Name}RemoteDataSource.swift    # Contract + Implementation
│       │   └── {Name}MemoryDataSource.swift    # Contract + Actor Implementation
│       └── DTOs/
│           └── {Name}DTO.swift                  # Data Transfer Objects (internal)
└── Tests/
    ├── Data/
    │   ├── {Name}RemoteDataSourceTests.swift    # Tests
    │   └── {Name}MemoryDataSourceTests.swift    # Tests
    ├── Fixtures/
    │   ├── {name}.json                          # JSON fixture replicating API response
    │   └── {name}_list.json                     # JSON fixture for list responses
    └── Mocks/
        ├── {Name}RemoteDataSourceMock.swift     # Mock (internal to tests)
        └── {Name}MemoryDataSourceMock.swift     # Mock (internal to tests)
```

> **Note:** DataSource mocks are placed in `Tests/Mocks/` because they use internal DTOs and are only needed within the feature's test target.

## API Configuration

Base URLs are defined in `Libraries/Core/Sources/API/APIConfiguration.swift`:

```swift
public enum APIConfiguration {
    case example
    // Add new APIs here

    public var baseURL: URL {
        switch self {
        case .example:
            // Safe: compile-time constant, will crash at app launch if invalid
            guard let url = URL(string: "https://api.example.com") else {
                fatalError("Invalid API base URL")
            }
            return url
        }
    }
}
```

> **Note:** Add new cases for each API your app consumes.

## RemoteDataSource Pattern

### 1. Contract (Protocol)

```swift
protocol {Name}RemoteDataSourceContract: Sendable {
    func fetch{Name}(id: Int) async throws -> {Name}DTO
    func fetchAll{Name}s() async throws -> [{Name}DTO]
}
```

**Rules:**
- `Contract` suffix in the name
- **Internal visibility** (not public) - DataSources are implementation details
- Conform to `Sendable`
- Methods are `async throws`
- Return DTOs, not domain models

### 2. Implementation

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

**Rules:**
- **Internal visibility** (not public)
- Inject `HTTPClientContract` (not the concrete implementation)
- Use `Endpoint` to define requests
- `HTTPClient` automatically decodes the response

### 3. DTO (Data Transfer Object)

```swift
nonisolated struct {Name}DTO: Decodable, Equatable {
    let id: Int
    let name: String
    // Properties matching the API JSON response
}
```

**Rules:**
- `DTO` suffix in the name
- **Never public** - DTOs are internal implementation details of the Data layer
- Mark as `nonisolated` to allow usage inside actors (e.g., MemoryDataSource)
- Conform to `Decodable` and `Equatable`
- Use `let` properties (immutable)
- Property names must match JSON keys (or use CodingKeys)
- Do not mark as `Sendable` explicitly (inferred by compiler)

### 4. Mock (in Tests/Mocks/)

```swift
import Foundation

@testable import Challenge{FeatureName}

final class {Name}RemoteDataSourceMock: {Name}RemoteDataSourceContract, @unchecked Sendable {
    var result: Result<{Name}DTO, Error> = .failure(NotConfiguredError.notConfigured)
    private(set) var fetchCallCount = 0
    private(set) var lastFetchedId: Int?

    func fetch{Name}(id: Int) async throws -> {Name}DTO {
        fetchCallCount += 1
        lastFetchedId = id
        return try result.get()
    }
}

private enum NotConfiguredError: Error {
    case notConfigured
}
```

**Rules:**
- `Mock` suffix in the name
- **Internal visibility** - placed in `Tests/Mocks/`, not in `Mocks/` framework
- **Requires `@testable import`** to access internal types (Contract, DTO)
- `@unchecked Sendable` if it has mutable state
- Properties for call tracking
- Configurable result using `Result`
- Default result should be `.failure` to catch unconfigured mocks

---

## MemoryDataSource Pattern

MemoryDataSource stores data in memory using **actors** to guarantee thread safety and prevent race conditions.

### 1. Contract (Protocol)

```swift
protocol {Name}MemoryDataSourceContract: Sendable {
    func get{Name}(id: Int) async -> {Name}DTO?
    func getAll{Name}s() async -> [{Name}DTO]
    func save{Name}(_ item: {Name}DTO) async
    func save{Name}s(_ items: [{Name}DTO]) async
    func delete{Name}(id: Int) async
    func deleteAll{Name}s() async
}
```

**Rules:**
- `Contract` suffix in the name
- **Internal visibility** (not public)
- Conform to `Sendable`
- All methods are `async` (actor isolation)
- Methods don't throw - memory operations are infallible
- Return optional for single item retrieval (may not exist)

### 2. Implementation (Actor)

```swift
actor {Name}MemoryDataSource: {Name}MemoryDataSourceContract {
    private var storage: [Int: {Name}DTO] = [:]

    func get{Name}(id: Int) -> {Name}DTO? {
        storage[id]
    }

    func getAll{Name}s() -> [{Name}DTO] {
        Array(storage.values)
    }

    func save{Name}(_ item: {Name}DTO) {
        storage[item.id] = item
    }

    func save{Name}s(_ items: [{Name}DTO]) {
        for item in items {
            storage[item.id] = item
        }
    }

    func delete{Name}(id: Int) {
        storage.removeValue(forKey: id)
    }

    func deleteAll{Name}s() {
        storage.removeAll()
    }
}
```

**Rules:**
- Use `actor` keyword (not struct/class)
- **Internal visibility** (not public)
- No `async` keyword in method signatures (actors implicitly isolate)
- Use dictionary for O(1) lookups by ID
- No manual synchronization needed - actor provides it

### 3. Mock (in Tests/Mocks/)

```swift
import Foundation

@testable import Challenge{FeatureName}

actor {Name}MemoryDataSourceMock: {Name}MemoryDataSourceContract {
    private var storage: [Int: {Name}DTO] = [:]
    private(set) var saveCallCount = 0
    private(set) var deleteCallCount = 0

    func get{Name}(id: Int) -> {Name}DTO? {
        storage[id]
    }

    func getAll{Name}s() -> [{Name}DTO] {
        Array(storage.values)
    }

    func save{Name}(_ item: {Name}DTO) {
        saveCallCount += 1
        storage[item.id] = item
    }

    func save{Name}s(_ items: [{Name}DTO]) {
        saveCallCount += 1
        for item in items {
            storage[item.id] = item
        }
    }

    func delete{Name}(id: Int) {
        deleteCallCount += 1
        storage.removeValue(forKey: id)
    }

    func deleteAll{Name}s() {
        deleteCallCount += 1
        storage.removeAll()
    }

    // Test helpers
    func setStorage(_ items: [{Name}DTO]) {
        storage = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    }
}
```

**Rules:**
- Use `actor` (same as implementation)
- **Internal visibility** - placed in `Tests/Mocks/`
- **Requires `@testable import`** to access internal types
- Properties for call tracking
- Helper methods for test setup

---

## Testing

### JSON Fixtures for DTOs

**DTOs use JSON files** that replicate real server responses. This ensures tests validate the actual API contract and catch deserialization issues.

**Location:** `Tests/Fixtures/`

```
FeatureName/
└── Tests/
    ├── Fixtures/                 # JSON files replicating server responses
    │   ├── character.json
    │   ├── character_list.json
    │   └── error_response.json
    ├── Extensions/
    │   └── Bundle+JSON.swift     # Helper to load JSON files
    ├── Data/
    │   └── {Name}RemoteDataSourceTests.swift
    └── Mocks/
```

**JSON file naming:**
- Use snake_case for file names: `character.json`, `character_list.json`
- Name should describe the content: `user.json`, `users_page_1.json`, `error_404.json`

**Example JSON fixture:**

```json
// Tests/Fixtures/character.json
{
    "id": 1,
    "name": "Rick Sanchez",
    "status": "Alive",
    "species": "Human",
    "gender": "Male",
    "origin": {
        "name": "Earth (C-137)",
        "url": "https://rickandmortyapi.com/api/location/1"
    },
    "location": {
        "name": "Citadel of Ricks",
        "url": "https://rickandmortyapi.com/api/location/3"
    },
    "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
    "url": "https://rickandmortyapi.com/api/character/1",
    "created": "2017-11-04T18:48:46.250Z"
}
```

**Loading JSON in tests:**

The `Bundle+JSON` helper is located in `ChallengeCoreMocks` for reuse across all feature tests:

```swift
// Libraries/Core/Mocks/Bundle+JSON.swift
import Foundation

public extension Bundle {
    func loadJSON<T: Decodable>(_ filename: String, as type: T.Type) throws -> T {
        guard let url = url(forResource: filename, withExtension: "json") else {
            throw JSONLoadError.fileNotFound(filename)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func loadJSONData(_ filename: String) throws -> Data {
        guard let url = url(forResource: filename, withExtension: "json") else {
            throw JSONLoadError.fileNotFound(filename)
        }
        return try Data(contentsOf: url)
    }
}

public enum JSONLoadError: Error {
    case fileNotFound(String)
}
```

> **Note:** Import `ChallengeCoreMocks` in your test files to use the `loadJSON` and `loadJSONData` methods.

**Rules for JSON Fixtures:**
- Copy real API responses when possible
- Keep fixtures minimal but complete (include all required fields)
- Create separate files for different scenarios (success, error, empty list, etc.)
- Store in `Tests/Fixtures/` folder
- Add JSON files to the test target's resources in Tuist configuration

### RemoteDataSource Test

```swift
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import Challenge{FeatureName}

struct {Name}RemoteDataSourceTests {
    private let testBundle = Bundle(for: BundleToken.self)

    @Test
    func fetchesFromCorrectEndpoint() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("{name}")
        let httpClient = HTTPClientMock(result: .success(jsonData))
        let sut = {Name}RemoteDataSource(httpClient: httpClient)

        // When
        _ = try await sut.fetch{Name}(id: 1)

        // Then
        let endpoint = try #require(httpClient.requestedEndpoints.first)
        #expect(endpoint.path == "/{resource}/1")
        #expect(endpoint.method == .get)
    }

    @Test
    func decodesResponseCorrectly() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("{name}")
        let httpClient = HTTPClientMock(result: .success(jsonData))
        let sut = {Name}RemoteDataSource(httpClient: httpClient)

        // When
        let value = try await sut.fetch{Name}(id: 1)

        // Then
        #expect(value.id == 1)
        #expect(value.name == "Rick Sanchez")
    }

    @Test
    func throwsOnHTTPError() async throws {
        // Given
        let httpClient = HTTPClientMock(result: .failure(TestError.network))
        let sut = {Name}RemoteDataSource(httpClient: httpClient)

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.fetch{Name}(id: 1)
        }
    }
}

private final class BundleToken {}

private enum TestError: Error {
    case network
}
```

### MemoryDataSource Test

MemoryDataSource tests load DTOs from JSON fixtures to ensure consistency with the real API format:

```swift
import ChallengeCoreMocks
import Foundation
import Testing

@testable import Challenge{FeatureName}

struct {Name}MemoryDataSourceTests {
    private let testBundle = Bundle(for: BundleToken.self)

    @Test
    func savesAndRetrievesItem() async throws {
        // Given
        let expected: {Name}DTO = try testBundle.loadJSON("{name}", as: {Name}DTO.self)
        let sut = {Name}MemoryDataSource()

        // When
        await sut.save{Name}(expected)
        let value = await sut.get{Name}(id: expected.id)

        // Then
        #expect(value == expected)
    }

    @Test
    func returnsNilForNonExistentItem() async {
        // Given
        let sut = {Name}MemoryDataSource()

        // When
        let value = await sut.get{Name}(id: 999)

        // Then
        #expect(value == nil)
    }

    @Test
    func savesMultipleItems() async throws {
        // Given
        let items: [{Name}DTO] = try testBundle.loadJSON("{name}_list", as: [{Name}DTO].self)
        let sut = {Name}MemoryDataSource()

        // When
        await sut.save{Name}s(items)
        let value = await sut.getAll{Name}s()

        // Then
        #expect(value.count == items.count)
    }

    @Test
    func deletesItem() async throws {
        // Given
        let item: {Name}DTO = try testBundle.loadJSON("{name}", as: {Name}DTO.self)
        let sut = {Name}MemoryDataSource()
        await sut.save{Name}(item)

        // When
        await sut.delete{Name}(id: item.id)
        let value = await sut.get{Name}(id: item.id)

        // Then
        #expect(value == nil)
    }

    @Test
    func deletesAllItems() async throws {
        // Given
        let items: [{Name}DTO] = try testBundle.loadJSON("{name}_list", as: [{Name}DTO].self)
        let sut = {Name}MemoryDataSource()
        await sut.save{Name}s(items)

        // When
        await sut.deleteAll{Name}s()
        let value = await sut.getAll{Name}s()

        // Then
        #expect(value.isEmpty)
    }
}

private final class BundleToken {}
```

---

## Usage

### RemoteDataSource with HTTPClient

```swift
// Create the client with the API base URL
let httpClient = HTTPClient(baseURL: APIConfiguration.example.baseURL)

// Create the DataSource
let dataSource = {Name}RemoteDataSource(httpClient: httpClient)

// Fetch data
let item = try await dataSource.fetch{Name}(id: 1)
```

### MemoryDataSource

```swift
// Create the in-memory DataSource
let memoryDataSource = {Name}MemoryDataSource()

// Save data
await memoryDataSource.save{Name}(item)

// Retrieve data
let cached = await memoryDataSource.get{Name}(id: 1)

// Delete data
await memoryDataSource.delete{Name}(id: 1)
```

### Combined: Cache with Remote Fallback

```swift
// In a Repository, combine both data sources
struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract
    private let memoryDataSource: {Name}MemoryDataSourceContract

    func get{Name}(id: Int) async throws -> {Name} {
        // Try cache first
        if let cached = await memoryDataSource.get{Name}(id: id) {
            return cached.toDomain()
        }

        // Fetch from remote and cache
        let dto = try await remoteDataSource.fetch{Name}(id: id)
        await memoryDataSource.save{Name}(dto)
        return dto.toDomain()
    }
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| RemoteDataSource Contract | internal | `Sources/Data/DataSources/` |
| RemoteDataSource Implementation | internal | `Sources/Data/DataSources/` |
| MemoryDataSource Contract | internal | `Sources/Data/DataSources/` |
| MemoryDataSource Implementation (actor) | internal | `Sources/Data/DataSources/` |
| DTO | internal | `Sources/Data/DTOs/` |
| Mocks | internal | `Tests/Mocks/` |

---

## Checklists

### RemoteDataSource

- [ ] Create DTO with `nonisolated` and properties matching the JSON (internal)
- [ ] Create Contract with async throws methods (internal)
- [ ] Create Implementation injecting HTTPClientContract (internal)
- [ ] Create Mock in `Tests/Mocks/` with call tracking (internal)
- [ ] Create JSON fixture(s) in `Tests/Fixtures/` replicating real API responses
- [ ] Create tests importing `ChallengeCoreMocks` and using JSON fixtures
- [ ] Add module to Project.swift (include JSON files in test resources)
- [ ] Run `tuist generate`
- [ ] Run tests

### MemoryDataSource

- [ ] Create Contract with async methods (internal)
- [ ] Create actor Implementation with dictionary storage (internal)
- [ ] Create actor Mock in `Tests/Mocks/` with call tracking (internal)
- [ ] Create JSON fixture(s) in `Tests/Fixtures/` for test data
- [ ] Create tests importing `ChallengeCoreMocks` and using JSON fixtures
- [ ] Run `tuist generate`
- [ ] Run tests
