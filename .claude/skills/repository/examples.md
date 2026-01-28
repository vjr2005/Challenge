# Repository Examples

Complete implementation examples for different repository scenarios.

---

## Scenario 1: Remote Only

### Implementation

```swift
struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract

    init(remoteDataSource: {Name}RemoteDataSourceContract) {
        self.remoteDataSource = remoteDataSource
    }

    func get{Name}(id: Int) async throws -> {Name} {
        let dto = try await remoteDataSource.fetch{Name}(id: id)
        return dto.toDomain()
    }

    func getAll{Name}s() async throws -> [{Name}] {
        let dtos = try await remoteDataSource.fetchAll{Name}s()
        return dtos.map { $0.toDomain() }
    }
}
```

### Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RepositoryTests {
    @Test
    func getsModelFromRemoteDataSource() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

        // When
        let value = try await sut.get{Name}(id: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func callsRemoteDataSourceWithCorrectId() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

        // When
        _ = try await sut.get{Name}(id: 42)

        // Then
        #expect(remoteDataSourceMock.fetchCallCount == 1)
        #expect(remoteDataSourceMock.lastFetchedId == 42)
    }

    @Test
    func propagatesRemoteDataSourceError() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(TestError.network)
        let sut = {Name}Repository(remoteDataSource: remoteDataSourceMock)

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.get{Name}(id: 1)
        }
    }
}

private enum TestError: Error {
    case network
}
```

---

## Scenario 2: Local Only

### Implementation

```swift
struct {Name}Repository: {Name}RepositoryContract {
    private let memoryDataSource: {Name}MemoryDataSourceContract

    init(memoryDataSource: {Name}MemoryDataSourceContract) {
        self.memoryDataSource = memoryDataSource
    }

    func get{Name}(id: Int) async throws -> {Name} {
        guard let dto = await memoryDataSource.get{Name}(id: id) else {
            throw {Name}RepositoryError.notFound
        }
        return dto.toDomain()
    }

    func getAll{Name}s() async throws -> [{Name}] {
        let dtos = await memoryDataSource.getAll{Name}s()
        return dtos.map { $0.toDomain() }
    }

    func save{Name}(_ model: {Name}) async {
        let dto = model.toDTO()
        await memoryDataSource.save{Name}(dto)
    }
}

enum {Name}RepositoryError: Error {
    case notFound
}
```

### Domain to DTO Mapping

```swift
extension {Name} {
    func toDTO() -> {Name}DTO {
        {Name}DTO(id: id, name: name)
    }
}
```

### Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RepositoryTests {
    @Test
    func getsModelFromMemoryDataSource() async throws {
        // Given
        let expected = {Name}.stub()
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        memoryDataSourceMock.itemToReturn = .stub()
        let sut = {Name}Repository(memoryDataSource: memoryDataSourceMock)

        // When
        let value = try await sut.get{Name}(id: expected.id)

        // Then
        #expect(value == expected)
    }

    @Test
    func throwsNotFoundWhenItemDoesNotExist() async throws {
        // Given
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(memoryDataSource: memoryDataSourceMock)

        // When / Then
        await #expect(throws: {Name}RepositoryError.notFound) {
            _ = try await sut.get{Name}(id: 999)
        }
    }

    @Test
    func savesModelToMemoryDataSource() async throws {
        // Given
        let model = {Name}.stub()
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(memoryDataSource: memoryDataSourceMock)

        // When
        await sut.save{Name}(model)

        // Then
        #expect(memoryDataSourceMock.saveCallCount == 1)
        #expect(memoryDataSourceMock.saveLastValue == model.toDTO())
    }
}
```

---

## Scenario 3: Local-First (Both DataSources)

### Implementation

```swift
struct {Name}Repository: {Name}RepositoryContract {
    private let remoteDataSource: {Name}RemoteDataSourceContract
    private let memoryDataSource: {Name}MemoryDataSourceContract

    init(
        remoteDataSource: {Name}RemoteDataSourceContract,
        memoryDataSource: {Name}MemoryDataSourceContract
    ) {
        self.remoteDataSource = remoteDataSource
        self.memoryDataSource = memoryDataSource
    }

    func get{Name}(id: Int) async throws -> {Name} {
        // 1. Check local cache first
        if let cachedDTO = await memoryDataSource.get{Name}(id: id) {
            return cachedDTO.toDomain()
        }

        // 2. Fetch from remote
        let dto = try await remoteDataSource.fetch{Name}(id: id)

        // 3. Save to cache
        await memoryDataSource.save{Name}(dto)

        // 4. Return domain model
        return dto.toDomain()
    }

    func getAll{Name}s() async throws -> [{Name}] {
        // 1. Check local cache first
        let cachedDTOs = await memoryDataSource.getAll{Name}s()
        if !cachedDTOs.isEmpty {
            return cachedDTOs.map { $0.toDomain() }
        }

        // 2. Fetch from remote
        let dtos = try await remoteDataSource.fetchAll{Name}s()

        // 3. Save to cache
        await memoryDataSource.save{Name}s(dtos)

        // 4. Return domain models
        return dtos.map { $0.toDomain() }
    }
}
```

### Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RepositoryTests {
    // MARK: - Cache Hit Tests

    @Test
    func returnsCachedDataWhenAvailable() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        memoryDataSourceMock.itemToReturn = .stub()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(id: expected.id)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 0)
    }

    @Test
    func doesNotCallRemoteWhenCacheHit() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        memoryDataSourceMock.itemToReturn = .stub()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try await sut.get{Name}(id: 1)

        // Then
        #expect(remoteDataSourceMock.fetchCallCount == 0)
    }

    // MARK: - Cache Miss Tests

    @Test
    func fetchesFromRemoteWhenCacheMiss() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(id: 1)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
    }

    @Test
    func savesToCacheAfterRemoteFetch() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try await sut.get{Name}(id: 1)

        // Then
        #expect(memoryDataSourceMock.saveCallCount == 1)
        #expect(memoryDataSourceMock.saveLastValue == .stub())
    }

    // MARK: - Error Tests

    @Test
    func propagatesRemoteErrorOnCacheMiss() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(TestError.network)
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.get{Name}(id: 1)
        }
    }

    @Test
    func doesNotSaveToCacheOnRemoteError() async throws {
        // Given
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(TestError.network)
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try? await sut.get{Name}(id: 1)

        // Then
        #expect(memoryDataSourceMock.saveCallCount == 0)
    }
}

private enum TestError: Error {
    case network
}
```

---

## Complete Example: Character (Local-First with Typed Throws)

### Domain Error

```swift
// Sources/Domain/Errors/CharacterError.swift
import ChallengeResources
import Foundation

public enum CharacterError: Error, Equatable, Sendable, LocalizedError {
    case loadFailed
    case characterNotFound(id: Int)
    case invalidPage(page: Int)

    public var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "characterError.loadFailed".localized()
        case .characterNotFound(let id):
            return "characterError.characterNotFound %lld".localized(id)
        case .invalidPage(let page):
            return "characterError.invalidPage %lld".localized(page)
        }
    }
}
```

### Domain Model

```swift
// Sources/Domain/Models/Character.swift
struct Character: Equatable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let gender: CharacterGender
}

enum CharacterStatus: Sendable {
    case alive
    case dead
    case unknown

    init(from string: String) {
        switch string.lowercased() {
        case "alive": self = .alive
        case "dead": self = .dead
        default: self = .unknown
        }
    }
}

enum CharacterGender: Sendable {
    case male
    case female
    case genderless
    case unknown

    init(from string: String) {
        switch string.lowercased() {
        case "male": self = .male
        case "female": self = .female
        case "genderless": self = .genderless
        default: self = .unknown
        }
    }
}
```

### Contract

```swift
// Sources/Domain/Repositories/CharacterRepositoryContract.swift
protocol CharacterRepositoryContract: Sendable {
    func getCharacter(identifier: Int) async throws(CharacterError) -> Character
}
```

### Implementation

```swift
// Sources/Data/Repositories/CharacterRepository.swift
import ChallengeNetworking

struct CharacterRepository: CharacterRepositoryContract {
    private let remoteDataSource: CharacterRemoteDataSourceContract
    private let memoryDataSource: CharacterMemoryDataSourceContract

    init(
        remoteDataSource: CharacterRemoteDataSourceContract,
        memoryDataSource: CharacterMemoryDataSourceContract
    ) {
        self.remoteDataSource = remoteDataSource
        self.memoryDataSource = memoryDataSource
    }

    func getCharacter(identifier: Int) async throws(CharacterError) -> Character {
        if let cachedDTO = await memoryDataSource.getCharacter(identifier: identifier) {
            return cachedDTO.toDomain()
        }

        do {
            let dto = try await remoteDataSource.fetchCharacter(identifier: identifier)
            await memoryDataSource.saveCharacter(dto)
            return dto.toDomain()
        } catch let error as HTTPError {
            throw mapHTTPError(error, identifier: identifier)
        } catch {
            throw .loadFailed
        }
    }
}

// MARK: - Error Mapping

private extension CharacterRepository {
    func mapHTTPError(_ error: HTTPError, identifier: Int) -> CharacterError {
        switch error {
        case .statusCode(404, _):
            return .characterNotFound(id: identifier)
        case .invalidURL, .invalidResponse, .statusCode:
            return .loadFailed
        }
    }
}

// MARK: - DTO to Domain Mapping

extension CharacterDTO {
    func toDomain() -> Character {
        Character(
            id: id,
            name: name,
            status: CharacterStatus(from: status),
            species: species,
            gender: CharacterGender(from: gender)
        )
    }
}
```

### Mock

```swift
// Tests/Mocks/CharacterRepositoryMock.swift
import Foundation

@testable import {AppName}Character

final class CharacterRepositoryMock: CharacterRepositoryContract, @unchecked Sendable {
    var result: Result<Character, CharacterError> = .failure(.loadFailed)
    private(set) var getCallCount = 0
    private(set) var lastRequestedIdentifier: Int?

    func getCharacter(identifier: Int) async throws(CharacterError) -> Character {
        getCallCount += 1
        lastRequestedIdentifier = identifier
        return try result.get()
    }
}
```

### Error Tests

```swift
// Tests/Domain/Errors/CharacterErrorTests.swift
import Foundation
import Testing

@testable import {AppName}Character

struct CharacterErrorTests {
    @Test(arguments: [
        (CharacterError.loadFailed, CharacterError.loadFailed, true),
        (CharacterError.characterNotFound(id: 1), CharacterError.characterNotFound(id: 1), true),
        (CharacterError.characterNotFound(id: 1), CharacterError.characterNotFound(id: 2), false),
        (CharacterError.loadFailed, CharacterError.characterNotFound(id: 1), false)
    ])
    func equality(lhs: CharacterError, rhs: CharacterError, expectedEqual: Bool) {
        // When
        let areEqual = lhs == rhs

        // Then
        #expect(areEqual == expectedEqual)
    }

    @Test
    func loadFailedErrorDescription() {
        // Given
        let sut = CharacterError.loadFailed

        // When
        let description = sut.errorDescription

        // Then
        #expect(description != nil)
    }

    @Test
    func characterNotFoundErrorDescription() {
        // Given
        let sut = CharacterError.characterNotFound(id: 42)

        // When
        let description = sut.errorDescription

        // Then
        #expect(description != nil)
    }
}
```
