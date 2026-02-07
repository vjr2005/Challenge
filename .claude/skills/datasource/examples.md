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
    // MARK: - Single Item (Detail)
    func get{Name}Detail(identifier: Int) async -> {Name}DTO?
    func save{Name}Detail(_ item: {Name}DTO) async
    func delete{Name}Detail(identifier: Int) async

    // MARK: - Paginated Results
    func getPage(_ page: Int) async -> {Name}sResponseDTO?
    func savePage(_ response: {Name}sResponseDTO, page: Int) async
    func clearPages() async
}
```

### Implementation

```swift
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

    func delete{Name}Detail(identifier: Int) {
        items.removeValue(forKey: identifier)
    }

    // MARK: - Paginated Results

    func getPage(_ page: Int) -> {Name}sResponseDTO? {
        pages[page]
    }

    func savePage(_ response: {Name}sResponseDTO, page: Int) {
        pages[page] = response
    }

    func clearPages() {
        pages.removeAll()
    }
}
```

### Mock

```swift
import Foundation

@testable import {AppName}{Feature}

final class {Name}MemoryDataSourceMock: {Name}MemoryDataSourceContract, @unchecked Sendable {
    // MARK: - Configurable Returns

    var detailToReturn: {Name}DTO?
    var pageToReturn: {Name}sResponseDTO?

    // MARK: - Call Tracking

    private(set) var get{Name}DetailCallCount = 0
    private(set) var save{Name}DetailCallCount = 0
    private(set) var lastSavedDetail: {Name}DTO?
    private(set) var delete{Name}DetailCallCount = 0
    private(set) var getPageCallCount = 0
    private(set) var savePageCallCount = 0
    private(set) var clearPagesCallCount = 0

    // MARK: - {Name}MemoryDataSourceContract

    func get{Name}Detail(identifier: Int) -> {Name}DTO? {
        get{Name}DetailCallCount += 1
        return detailToReturn
    }

    func save{Name}Detail(_ item: {Name}DTO) {
        save{Name}DetailCallCount += 1
        lastSavedDetail = item
    }

    func delete{Name}Detail(identifier: Int) {
        delete{Name}DetailCallCount += 1
    }

    func getPage(_ page: Int) -> {Name}sResponseDTO? {
        getPageCallCount += 1
        return pageToReturn
    }

    func savePage(_ response: {Name}sResponseDTO, page: Int) {
        savePageCallCount += 1
    }

    func clearPages() {
        clearPagesCallCount += 1
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
    @Test("Saves and retrieves detail item")
    func savesAndRetrievesDetail() async throws {
        // Given
        let expected: {Name}DTO = try loadJSON("{name}")
        let sut = {Name}MemoryDataSource()

        // When
        await sut.save{Name}Detail(expected)
        let value = await sut.get{Name}Detail(identifier: expected.id)

        // Then
        #expect(value == expected)
    }

    @Test("Returns nil for non-existent detail")
    func returnsNilForNonExistentDetail() async {
        // Given
        let sut = {Name}MemoryDataSource()

        // When
        let value = await sut.get{Name}Detail(identifier: 999)

        // Then
        #expect(value == nil)
    }

    @Test("Updates existing detail item")
    func updatesExistingDetail() async throws {
        // Given
        let original: {Name}DTO = try loadJSON("{name}")
        let updated: {Name}DTO = try loadJSON("{name}_updated")
        let sut = {Name}MemoryDataSource()
        await sut.save{Name}Detail(original)

        // When
        await sut.save{Name}Detail(updated)
        let value = await sut.get{Name}Detail(identifier: original.id)

        // Then
        #expect(value == updated)
    }

    @Test("Saves and retrieves page")
    func savesAndRetrievesPage() async throws {
        // Given
        let expected: {Name}sResponseDTO = try loadJSON("{name}s_response")
        let sut = {Name}MemoryDataSource()

        // When
        await sut.savePage(expected, page: 1)
        let value = await sut.getPage(1)

        // Then
        #expect(value == expected)
    }

    @Test("Returns nil for non-existent page")
    func returnsNilForNonExistentPage() async {
        // Given
        let sut = {Name}MemoryDataSource()

        // When
        let value = await sut.getPage(999)

        // Then
        #expect(value == nil)
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
import ChallengeCore

struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract
    private let memoryDataSource: {Name}MemoryDataSourceContract

    func get{Name}Detail(identifier: Int, cachePolicy: CachePolicy) async throws -> {Name} {
        switch cachePolicy {
        case .localFirst:
            // Try cache first
            if let cached = await memoryDataSource.get{Name}Detail(identifier: identifier) {
                return cached.toDomain()
            }
            // Fetch from remote and cache
            let dto = try await remoteDataSource.fetch{Name}(identifier: identifier)
            await memoryDataSource.save{Name}Detail(dto)
            return dto.toDomain()

        case .remoteFirst:
            // Always fetch from remote, fallback to cache on error
            // ...

        case .none:
            // Only remote, no cache
            // ...
        }
    }
}
```
