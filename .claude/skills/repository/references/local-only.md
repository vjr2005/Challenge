# Local Only Repository

Implementation and tests for a repository that only uses a LocalDataSource (UserDefaults).

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
    private(set) var get{Name}CallCount = 0
    private(set) var lastRequestedIdentifier: Int?
    private(set) var save{Name}CallCount = 0
    private(set) var lastSavedModel: {Name}?

    func get{Name}(identifier: Int) async throws({Feature}Error) -> {Name} {
        get{Name}CallCount += 1
        lastRequestedIdentifier = identifier
        return try getResult.get()
    }

    func save{Name}(_ model: {Name}) async {
        save{Name}CallCount += 1
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
        await localDataSourceMock.setItemToReturn(try loadJSON("{name}"))
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
    func savesModelToLocalDataSource() async throws {
        // Given
        let model = {Name}.stub()
        let localDataSourceMock = {Name}LocalDataSourceMock()
        let sut = {Name}Repository(localDataSource: localDataSourceMock)

        // When
        await sut.save{Name}(model)

        // Then
        #expect(await localDataSourceMock.saveCallCount == 1)
        #expect(await localDataSourceMock.saveLastValue == model.toDTO())
    }
}
```
