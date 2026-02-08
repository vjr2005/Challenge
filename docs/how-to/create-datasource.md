# How To: Create DataSource

Create DataSources for data access: RemoteDataSource for REST APIs, MemoryDataSource for in-memory caching.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- API endpoint identified
- JSON response structure known

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
    ├── Unit/
    │   └── Data/
    │       ├── {Name}RemoteDataSourceTests.swift
    │       └── {Name}MemoryDataSourceTests.swift
    └── Shared/
        ├── Mocks/
        │   ├── {Name}RemoteDataSourceMock.swift
        │   └── {Name}MemoryDataSourceMock.swift
        └── Fixtures/
            └── {name}.json
```

---

## Part A: Create RemoteDataSource

### 1. Create DTO

> *"A Data Transfer Object is one of those objects our mothers told us never to write. It's often little more than a bunch of fields and the getters and setters for them."*
> — Martin Fowler, [Patterns of Enterprise Application Architecture](https://martinfowler.com/eaaCatalog/dataTransferObject.html)

Create `Sources/Data/DTOs/{Name}DTO.swift`:

```swift
import Foundation

struct {Name}DTO: Decodable, Equatable {
    let id: Int
    let name: String
    // Add properties matching JSON keys
}
```

> **Note:** DTOs are intentionally anemic - they exist purely to transfer data. No behavior, no `toDomain()` methods. Mapping belongs in the Repository.

### 2. Create RemoteDataSource

Create `Sources/Data/DataSources/{Name}RemoteDataSource.swift`:

```swift
import ChallengeNetworking
import Foundation

protocol {Name}RemoteDataSourceContract: Sendable {
    func fetch{Name}(identifier: Int) async throws -> {Name}DTO
}

struct {Name}RemoteDataSource: {Name}RemoteDataSourceContract {
    private let httpClient: HTTPClientContract

    init(httpClient: HTTPClientContract) {
        self.httpClient = httpClient
    }

    func fetch{Name}(identifier: Int) async throws -> {Name}DTO {
        let endpoint = Endpoint(path: "/{resource}/\(identifier)")
        return try await httpClient.request(endpoint)
    }
}
```

### 3. Create JSON fixture

Create `Tests/Shared/Fixtures/{name}.json`:

```json
{
    "id": 1,
    "name": "Example"
}
```

### 4. Create Mock

Create `Tests/Shared/Mocks/{Name}RemoteDataSourceMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}RemoteDataSourceMock: {Name}RemoteDataSourceContract, @unchecked Sendable {
    var result: Result<{Name}DTO, Error> = .failure(NotConfiguredError.notConfigured)
    private(set) var fetchCallCount = 0
    private(set) var lastFetchedIdentifier: Int?

    func fetch{Name}(identifier: Int) async throws -> {Name}DTO {
        fetchCallCount += 1
        lastFetchedIdentifier = identifier
        return try result.get()
    }
}

private enum NotConfiguredError: Error {
    case notConfigured
}
```

### 5. Create tests

Create `Tests/Unit/Data/{Name}RemoteDataSourceTests.swift`:

```swift
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}RemoteDataSourceTests {
    private let httpClientMock = HTTPClientMock()
    private let sut: {Name}RemoteDataSource

    init() {
        sut = {Name}RemoteDataSource(httpClient: httpClientMock)
    }

    // MARK: - Endpoint Tests

    @Test("Fetch uses correct endpoint path")
    func fetchUsesCorrectEndpoint() async throws {
        // Given
        let jsonData = try loadJSONData("{name}")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetch{Name}(identifier: 1)

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        #expect(endpoint.path == "/{resource}/1")
        #expect(endpoint.method == .get)
    }

    // MARK: - Decoding Tests

    @Test("Fetch decodes response correctly")
    func fetchDecodesResponseCorrectly() async throws {
        // Given
        let jsonData = try loadJSONData("{name}")
        httpClientMock.result = .success(jsonData)

        // When
        let value = try await sut.fetch{Name}(identifier: 1)

        // Then
        #expect(value.id == 1)
        #expect(value.name == "Example")
    }

    // MARK: - Error Tests

    @Test("Fetch throws on HTTP error")
    func fetchThrowsOnHTTPError() async throws {
        // Given
        httpClientMock.result = .failure(TestError.network)

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.fetch{Name}(identifier: 1)
        }
    }
}

// MARK: - Private

private extension {Name}RemoteDataSourceTests {
    func loadJSONData(_ filename: String) throws -> Data {
        try Bundle.module.loadJSONData(filename)
    }
}

private enum TestError: Error {
    case network
}
```

---

## Part B: Create MemoryDataSource

### 1. Create MemoryDataSource

Create `Sources/Data/DataSources/{Name}MemoryDataSource.swift`:

```swift
import Foundation

protocol {Name}MemoryDataSourceContract: Sendable {
    // MARK: - Single Item (Detail)
    func get{Name}Detail(identifier: Int) async -> {Name}DTO?
    func save{Name}Detail(_ item: {Name}DTO) async

    // MARK: - Paginated Results (optional)
    func getPage(_ page: Int) async -> {Name}sResponseDTO?
    func savePage(_ response: {Name}sResponseDTO, page: Int) async
}

actor {Name}MemoryDataSource: {Name}MemoryDataSourceContract {
    private var items: [Int: {Name}DTO] = [:]
    private var pages: [Int: {Name}sResponseDTO] = [:]

    // MARK: - Single Item

    func get{Name}Detail(identifier: Int) -> {Name}DTO? {
        items[identifier]
    }

    func save{Name}Detail(_ item: {Name}DTO) {
        items[item.id] = item
    }

    // MARK: - Paginated Results

    func getPage(_ page: Int) -> {Name}sResponseDTO? {
        pages[page]
    }

    func savePage(_ response: {Name}sResponseDTO, page: Int) {
        pages[page] = response
    }
}
```

> **Note:** Use `actor` for thread-safe storage. Methods inside actor don't need `async` keyword in implementation. Use `Detail` suffix for single-item methods.

### 2. Create Mock

Create `Tests/Shared/Mocks/{Name}MemoryDataSourceMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}MemoryDataSourceMock: {Name}MemoryDataSourceContract, @unchecked Sendable {
    var detailToReturn: {Name}DTO?
    var pageToReturn: {Name}sResponseDTO?
    private(set) var get{Name}DetailCallCount = 0
    private(set) var save{Name}DetailCallCount = 0
    private(set) var lastSavedDetail: {Name}DTO?
    private(set) var getPageCallCount = 0
    private(set) var savePageCallCount = 0

    func get{Name}Detail(identifier: Int) async -> {Name}DTO? {
        get{Name}DetailCallCount += 1
        return detailToReturn
    }

    func save{Name}Detail(_ item: {Name}DTO) async {
        save{Name}DetailCallCount += 1
        lastSavedDetail = item
    }

    func getPage(_ page: Int) async -> {Name}sResponseDTO? {
        getPageCallCount += 1
        return pageToReturn
    }

    func savePage(_ response: {Name}sResponseDTO, page: Int) async {
        savePageCallCount += 1
    }
}
```

### 3. Create tests

Create `Tests/Unit/Data/{Name}MemoryDataSourceTests.swift`:

```swift
import Testing

@testable import Challenge{Feature}

struct {Name}MemoryDataSourceTests {
    private let sut = {Name}MemoryDataSource()

    // MARK: - Get Detail Tests

    @Test("Get detail returns nil when not stored")
    func getDetailReturnsNilWhenNotStored() async {
        // When
        let result = await sut.get{Name}Detail(identifier: 1)

        // Then
        #expect(result == nil)
    }

    @Test("Get detail returns stored item")
    func getDetailReturnsStoredItem() async {
        // Given
        let item = {Name}DTO(id: 1, name: "Test")
        await sut.save{Name}Detail(item)

        // When
        let result = await sut.get{Name}Detail(identifier: 1)

        // Then
        #expect(result == item)
    }

    // MARK: - Save Detail Tests

    @Test("Save detail overwrites existing item")
    func saveDetailOverwritesExistingItem() async {
        // Given
        let original = {Name}DTO(id: 1, name: "Original")
        let updated = {Name}DTO(id: 1, name: "Updated")
        await sut.save{Name}Detail(original)

        // When
        await sut.save{Name}Detail(updated)

        // Then
        let result = await sut.get{Name}Detail(identifier: 1)
        #expect(result?.name == "Updated")
    }
}
```

---

## Generate and verify

```bash
./generate.sh
```

## Next steps

- [Create Repository](create-repository.md) - Create data abstraction using these DataSources

## See also

- [Project Structure](../ProjectStructure.md)
- [Testing](../Testing.md)
