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

## Scenario 3: Both DataSources with CachePolicy

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

    func get{Name}(id: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        switch cachePolicy {
        case .localFirst:
            try await getLocalFirst(id: id)
        case .remoteFirst:
            try await getRemoteFirst(id: id)
        case .noCache:
            try await getNoCache(id: id)
        }
    }
}

// MARK: - Remote Fetch Helper

private extension {Name}Repository {
    func fetchFromRemote(id: Int) async throws({Feature}Error) -> {Name}DTO {
        do {
            return try await remoteDataSource.fetch{Name}(id: id)
        } catch let error as HTTPError {
            throw mapHTTPError(error, id: id)
        } catch {
            throw .loadFailed
        }
    }
}

// MARK: - Cache Strategies

private extension {Name}Repository {
    func getLocalFirst(id: Int) async throws({Feature}Error) -> {Name} {
        if let cached = await memoryDataSource.get{Name}(id: id) {
            return cached.toDomain()
        }
        let dto = try await fetchFromRemote(id: id)
        await memoryDataSource.save{Name}(dto)
        return dto.toDomain()
    }

    func getRemoteFirst(id: Int) async throws({Feature}Error) -> {Name} {
        do {
            let dto = try await fetchFromRemote(id: id)
            await memoryDataSource.save{Name}(dto)
            return dto.toDomain()
        } catch {
            if let cached = await memoryDataSource.get{Name}(id: id) {
                return cached.toDomain()
            }
            throw error
        }
    }

    func getNoCache(id: Int) async throws({Feature}Error) -> {Name} {
        let dto = try await fetchFromRemote(id: id)
        return dto.toDomain()
    }
}
```

### Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RepositoryTests {
    // MARK: - LocalFirst Tests

    @Test("LocalFirst returns cached data when available")
    func localFirstReturnsCachedData() async throws {
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
        let value = try await sut.get{Name}(id: expected.id, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 0)
    }

    @Test("LocalFirst fetches from remote on cache miss")
    func localFirstFetchesFromRemoteOnCacheMiss() async throws {
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
        let value = try await sut.get{Name}(id: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
        #expect(memoryDataSourceMock.saveCallCount == 1)
    }

    // MARK: - RemoteFirst Tests

    @Test("RemoteFirst fetches from remote and saves to cache")
    func remoteFirstFetchesFromRemote() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        memoryDataSourceMock.itemToReturn = .stub() // Cache has data
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(id: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1) // Always calls remote
        #expect(memoryDataSourceMock.saveCallCount == 1)
    }

    @Test("RemoteFirst falls back to cache on error")
    func remoteFirstFallsBackToCache() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .failure(.loadFailed)
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        memoryDataSourceMock.itemToReturn = .stub()
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(id: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == expected)
    }

    // MARK: - NoCache Tests

    @Test("NoCache always fetches from remote")
    func noCacheAlwaysFetchesFromRemote() async throws {
        // Given
        let expected = {Name}.stub()
        let remoteDataSourceMock = {Name}RemoteDataSourceMock()
        remoteDataSourceMock.result = .success(.stub())
        let memoryDataSourceMock = {Name}MemoryDataSourceMock()
        memoryDataSourceMock.itemToReturn = .stub() // Cache has data
        let sut = {Name}Repository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.get{Name}(id: 1, cachePolicy: .noCache)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCallCount == 1)
        #expect(memoryDataSourceMock.saveCallCount == 0) // Does not save
    }
}
```

---

## Complete Example: Character (CachePolicy with Typed Throws)

### CachePolicy

`CachePolicy` is defined in `ChallengeCore` and shared across all features:

```swift
// Libraries/Core/Sources/Data/CachePolicy.swift
public enum CachePolicy: Sendable {
    case localFirst   // Cache first, remote if not found. Default behavior.
    case remoteFirst  // Remote first, cache as fallback on error.
    case noCache      // Only remote, no cache interaction.
}
```

### Domain Errors

```swift
// Sources/Domain/Errors/CharacterError.swift (for detail operations)
import ChallengeResources
import Foundation

public enum CharacterError: Error, Equatable, Sendable, LocalizedError {
    case loadFailed
    case notFound(identifier: Int)

    public var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "characterError.loadFailed".localized()
        case .notFound(let identifier):
            return "characterError.notFound %lld".localized(identifier)
        }
    }
}

// Sources/Domain/Errors/CharactersPageError.swift (for paginated list operations)
import ChallengeResources
import Foundation

public enum CharactersPageError: Error, Equatable, Sendable, LocalizedError {
    case loadFailed
    case invalidPage(page: Int)

    public var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "charactersPageError.loadFailed".localized()
        case .invalidPage(let page):
            return "charactersPageError.invalidPage %lld".localized(page)
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
```

### Contract

```swift
// Sources/Domain/Repositories/CharacterRepositoryContract.swift
import ChallengeCore

protocol CharacterRepositoryContract: Sendable {
    func getCharacterDetail(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
}

// Sources/Domain/Repositories/CharactersPageRepositoryContract.swift
import ChallengeCore

protocol CharactersPageRepositoryContract: Sendable {
    func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage
    func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage
}
```

**Naming Convention:**
- `getCharacterDetail` - singular item with `Detail` suffix
- `getCharactersPage` - plural with `Page` suffix for list operations
- `searchCharactersPage` - search with `Page` suffix
- Separate contracts per ISP: detail vs page operations

### Implementation

Each contract has its own implementation:

```swift
// Sources/Data/Repositories/CharacterRepository.swift
import ChallengeCore
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

    func getCharacterDetail(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
        switch cachePolicy {
        case .localFirst:
            try await getCharacterDetailLocalFirst(identifier: identifier)
        case .remoteFirst:
            try await getCharacterDetailRemoteFirst(identifier: identifier)
        case .noCache:
            try await getCharacterDetailNoCache(identifier: identifier)
        }
    }
}

// MARK: - Remote Fetch Helpers

private extension CharacterRepository {
    func fetchCharacterFromRemote(identifier: Int) async throws(CharacterError) -> CharacterDTO {
        do {
            return try await remoteDataSource.fetchCharacter(identifier: identifier)
        } catch let error as HTTPError {
            throw mapHTTPError(error, identifier: identifier)
        } catch {
            throw .loadFailed
        }
    }

    func fetchCharactersFromRemote(page: Int, query: String? = nil) async throws(CharactersPageError) -> CharactersResponseDTO {
        do {
            return try await remoteDataSource.fetchCharacters(page: page, query: query)
        } catch let error as HTTPError {
            throw mapPageHTTPError(error, page: page)
        } catch {
            throw .loadFailed
        }
    }
}

// MARK: - Character Detail Cache Strategies

private extension CharacterRepository {
    func getCharacterDetailLocalFirst(identifier: Int) async throws(CharacterError) -> Character {
        if let cached = await memoryDataSource.getCharacterDetail(identifier: identifier) {
            return cached.toDomain()
        }
        let dto = try await fetchCharacterFromRemote(identifier: identifier)
        await memoryDataSource.saveCharacterDetail(dto)
        return dto.toDomain()
    }

    func getCharacterDetailRemoteFirst(identifier: Int) async throws(CharacterError) -> Character {
        do {
            let dto = try await fetchCharacterFromRemote(identifier: identifier)
            await memoryDataSource.saveCharacterDetail(dto)
            return dto.toDomain()
        } catch {
            if let cached = await memoryDataSource.getCharacterDetail(identifier: identifier) {
                return cached.toDomain()
            }
            throw error
        }
    }

    func getCharacterDetailNoCache(identifier: Int) async throws(CharacterError) -> Character {
        let dto = try await fetchCharacterFromRemote(identifier: identifier)
        return dto.toDomain()
    }
}

// MARK: - Error Mapping

private extension CharacterRepository {
    func mapHTTPError(_ error: HTTPError, identifier: Int) -> CharacterError {
        switch error {
        case .statusCode(404, _):
            .notFound(identifier: identifier)
        case .invalidURL, .invalidResponse, .statusCode:
            .loadFailed
        }
    }

    func mapPageHTTPError(_ error: HTTPError, page: Int) -> CharactersPageError {
        switch error {
        case .statusCode(404, _):
            .invalidPage(page: page)
        case .invalidURL, .invalidResponse, .statusCode:
            .loadFailed
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
import ChallengeCore
import Foundation

@testable import {AppName}Character

final class CharacterRepositoryMock: CharacterRepositoryContract, @unchecked Sendable {
    var result: Result<Character, CharacterError> = .failure(.loadFailed)
    private(set) var getCharacterDetailCallCount = 0
    private(set) var lastRequestedIdentifier: Int?
    private(set) var lastCharacterDetailCachePolicy: CachePolicy?

    func getCharacterDetail(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
        getCharacterDetailCallCount += 1
        lastRequestedIdentifier = identifier
        lastCharacterDetailCachePolicy = cachePolicy
        return try result.get()
    }
}

// Tests/Mocks/CharactersPageRepositoryMock.swift
final class CharactersPageRepositoryMock: CharactersPageRepositoryContract, @unchecked Sendable {
    var charactersResult: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed)
    var searchResult: Result<CharactersPage, CharactersPageError> = .failure(.loadFailed)
    private(set) var getCharactersPageCallCount = 0
    private(set) var searchCharactersPageCallCount = 0
    private(set) var lastRequestedPage: Int?
    private(set) var lastSearchedPage: Int?
    private(set) var lastSearchedFilter: CharacterFilter?
    private(set) var lastCharactersCachePolicy: CachePolicy?

    func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage {
        getCharactersPageCallCount += 1
        lastRequestedPage = page
        lastCharactersCachePolicy = cachePolicy
        return try charactersResult.get()
    }

    func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
        searchCharactersPageCallCount += 1
        lastSearchedPage = page
        lastSearchedFilter = filter
        return try searchResult.get()
    }
}
```

### Tests

```swift
// Tests/Data/CharacterRepositoryTests.swift
import ChallengeCore
import ChallengeNetworking
import Foundation
import Testing

@testable import {AppName}Character

struct CharacterRepositoryTests {
    // MARK: - LocalFirst Tests

    @Test("LocalFirst returns cached character when available")
    func localFirstReturnsCachedCharacter() async throws {
        // Given
        let expected = Character.stub()
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        memoryDataSourceMock.characterDetailToReturn = .stub()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.getCharacterDetail(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 0)
    }

    @Test("LocalFirst fetches from remote on cache miss and saves")
    func localFirstFetchesFromRemoteOnCacheMiss() async throws {
        // Given
        let expected = Character.stub()
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.fetchCharacterResult = .success(.stub())
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.getCharacterDetail(identifier: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
        #expect(memoryDataSourceMock.saveCharacterDetailCallCount == 1)
    }

    // MARK: - RemoteFirst Tests

    @Test("RemoteFirst fetches from remote even when cached")
    func remoteFirstFetchesFromRemote() async throws {
        // Given
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.fetchCharacterResult = .success(.stub())
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        memoryDataSourceMock.characterDetailToReturn = .stub()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try await sut.getCharacterDetail(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
    }

    @Test("RemoteFirst falls back to cache on error")
    func remoteFirstFallsBackToCache() async throws {
        // Given
        let expected = Character.stub()
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.fetchCharacterResult = .failure(.invalidResponse)
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        memoryDataSourceMock.characterDetailToReturn = .stub()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        let value = try await sut.getCharacterDetail(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == expected)
    }

    // MARK: - NoCache Tests

    @Test("NoCache fetches from remote without saving")
    func noCacheFetchesFromRemoteWithoutSaving() async throws {
        // Given
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.fetchCharacterResult = .success(.stub())
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When
        _ = try await sut.getCharacterDetail(identifier: 1, cachePolicy: .noCache)

        // Then
        #expect(remoteDataSourceMock.fetchCharacterCallCount == 1)
        #expect(memoryDataSourceMock.saveCharacterDetailCallCount == 0)
    }

    // MARK: - Error Mapping Tests

    @Test("Maps 404 error to notFound")
    func maps404ToCharacterNotFound() async throws {
        // Given
        let remoteDataSourceMock = CharacterRemoteDataSourceMock()
        remoteDataSourceMock.fetchCharacterResult = .failure(.statusCode(404, nil))
        let memoryDataSourceMock = CharacterMemoryDataSourceMock()
        let sut = CharacterRepository(
            remoteDataSource: remoteDataSourceMock,
            memoryDataSource: memoryDataSourceMock
        )

        // When / Then
        await #expect(throws: CharacterError.notFound(identifier: 42)) {
            _ = try await sut.getCharacterDetail(identifier: 42, cachePolicy: .noCache)
        }
    }
}
```
