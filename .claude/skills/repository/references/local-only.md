# Local Only Repository

Implementation and tests for a repository that only uses a LocalDataSource (Memory or UserDefaults).

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## Implementation

```swift
struct {Name}Repository: {Name}RepositoryContract {
    private let localDataSource: {Name}LocalDataSourceContract
    private let mapper = {Name}Mapper()

    init(localDataSource: {Name}LocalDataSourceContract) {
        self.localDataSource = localDataSource
    }

    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
        guard let dto = await localDataSource.get{Name}(identifier: identifier) else {
            throw .notFound(identifier: identifier)
        }
        return mapper.map(dto)
    }

    func save{Name}(_ model: {Name}) async {
        await localDataSource.save{Name}(model.toDTO())
    }
}
```

## Domain to DTO Mapping

```swift
extension {Name} {
    func toDTO() -> {Name}DTO {
        {Name}DTO(id: id, name: name)
    }
}
```

## Mock

```swift
import Foundation

@testable import {AppName}{Feature}

final class {Name}RepositoryMock: {Name}RepositoryContract, @unchecked Sendable {
    var getResult: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
    private(set) var getCallCount = 0
    private(set) var lastRequestedIdentifier: Int?
    private(set) var saveCallCount = 0
    private(set) var lastSavedModel: {Name}?

    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
        getCallCount += 1
        lastRequestedIdentifier = identifier
        return try getResult.get()
    }

    func save{Name}(_ model: {Name}) async {
        saveCallCount += 1
        lastSavedModel = model
    }
}
```

## Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}RepositoryTests {
    @Test("Gets model from local data source")
    func getsModelFromLocalDataSource() async throws {
        // Given
        let expected = {Name}.stub()
        let localDataSourceMock = {Name}LocalDataSourceMock()
        localDataSourceMock.itemToReturn = .stub()
        let sut = {Name}Repository(localDataSource: localDataSourceMock)

        // When
        let value = try await sut.get{Name}(identifier: expected.id)

        // Then
        #expect(value == expected)
    }

    @Test("Throws notFound when item does not exist")
    func throwsNotFoundWhenItemDoesNotExist() async throws {
        // Given
        let localDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(localDataSource: localDataSourceMock)

        // When / Then
        await #expect(throws: {Feature}Error.notFound(identifier: 999)) {
            _ = try await sut.get{Name}(identifier: 999)
        }
    }

    @Test("Saves model to local data source")
    func savesModelToLocalDataSource() async {
        // Given
        let model = {Name}.stub()
        let localDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(localDataSource: localDataSourceMock)

        // When
        await sut.save{Name}(model)

        // Then
        #expect(localDataSourceMock.saveCallCount == 1)
        #expect(localDataSourceMock.saveLastValue == model.toDTO())
    }
}
```
