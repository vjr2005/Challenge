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

@testable import {AppName}{Feature}

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
import {AppName}CoreMocks
import {AppName}NetworkingMocks
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RemoteDataSourceTests {
    @Test
    func fetchesFromCorrectEndpoint() async throws {
        // Given
        let jsonData = try loadJSONData("{name}")
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
        let jsonData = try loadJSONData("{name}")
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

@testable import {AppName}{Feature}

final class {Name}MemoryDataSourceMock: {Name}MemoryDataSourceContract, @unchecked Sendable {
    // MARK: - Configurable Returns

    var itemToReturn: {Name}DTO?
    var allItemsToReturn: [{Name}DTO] = []

    // MARK: - Call Tracking

    private(set) var getCallCount = 0
    private(set) var getAllCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var saveLastValue: {Name}DTO?
    private(set) var saveAllCallCount = 0
    private(set) var deleteCallCount = 0
    private(set) var deleteAllCallCount = 0

    // MARK: - {Name}MemoryDataSourceContract

    func get{Name}(id: Int) -> {Name}DTO? {
        getCallCount += 1
        return itemToReturn
    }

    func getAll{Name}s() -> [{Name}DTO] {
        getAllCallCount += 1
        return allItemsToReturn
    }

    func save{Name}(_ item: {Name}DTO) {
        saveCallCount += 1
        saveLastValue = item
    }

    func save{Name}s(_ items: [{Name}DTO]) {
        saveAllCallCount += 1
    }

    func delete{Name}(id: Int) {
        deleteCallCount += 1
    }

    func deleteAll{Name}s() {
        deleteAllCallCount += 1
    }
}
```

### Tests

```swift
import {AppName}CoreMocks
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}MemoryDataSourceTests {
    @Test
    func savesAndRetrievesItem() async throws {
        // Given
        let expected: {Name}DTO = try loadJSON("{name}")
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
        let items: [{Name}DTO] = try loadJSON("{name}_list")
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
        let item: {Name}DTO = try loadJSON("{name}")
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
        let items: [{Name}DTO] = try loadJSON("{name}_list")
        let sut = {Name}MemoryDataSource()
        await sut.save{Name}s(items)

        // When
        await sut.deleteAll{Name}s()
        let value = await sut.getAll{Name}s()

        // Then
        #expect(value.isEmpty)
    }
}

// MARK: - Private

private extension {Name}MemoryDataSourceTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }
}
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
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        let data = try loadJSONData(filename)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func loadJSONData(_ filename: String) throws -> Data {
        guard let url = url(forResource: filename, withExtension: "json") else {
            throw JSONLoadError.fileNotFound(filename)
        }
        return try Data(contentsOf: url)
    }
}

public enum JSONLoadError: Error, CustomStringConvertible {
    case fileNotFound(String)

    public var description: String {
        switch self {
        case let .fileNotFound(filename):
            "JSON file '\(filename).json' not found in bundle"
        }
    }
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
