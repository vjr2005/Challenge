# DataSource Examples

Complete implementation examples for RemoteDataSource and MemoryDataSource.

---

## RemoteDataSource

### Contract

```swift
protocol {Name}RemoteDataSourceContract: Sendable {
    func fetch{Name}(id: Int) async throws -> {Name}DTO
    func fetchAll{Name}s() async throws -> [{Name}DTO]
}
```

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

    func fetchAll{Name}s() async throws -> [{Name}DTO] {
        let endpoint = Endpoint(path: "/{resource}")
        return try await httpClient.request(endpoint)
    }
}
```

### DTO

```swift
nonisolated struct {Name}DTO: Decodable, Equatable {
    let id: Int
    let name: String
    let status: String
    let species: String
}
```

### Mock

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

    func fetchAll{Name}s() async throws -> [{Name}DTO] {
        fetchCallCount += 1
        return [try result.get()]
    }
}

private enum NotConfiguredError: Error {
    case notConfigured
}
```

### Tests

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
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let sut = {Name}RemoteDataSource(httpClient: httpClientMock)

        // When
        _ = try await sut.fetch{Name}(id: 1)

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        #expect(endpoint.path == "/{resource}/1")
        #expect(endpoint.method == .get)
    }

    @Test
    func decodesResponseCorrectly() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("{name}")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let sut = {Name}RemoteDataSource(httpClient: httpClientMock)

        // When
        let value = try await sut.fetch{Name}(id: 1)

        // Then
        #expect(value.id == 1)
        #expect(value.name == "Rick Sanchez")
    }

    @Test
    func throwsOnHTTPError() async throws {
        // Given
        let httpClientMock = HTTPClientMock(result: .failure(TestError.network))
        let sut = {Name}RemoteDataSource(httpClient: httpClientMock)

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

---

## MemoryDataSource

### Contract

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

### Implementation

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

### Mock

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

    // Test helper
    func setStorage(_ items: [{Name}DTO]) {
        storage = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    }
}
```

### Tests

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

## JSON Fixture Example

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

---

## Bundle+JSON Helper

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

---

## Usage in Repository

```swift
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
