# Business Logic UseCase

For operations that include domain rules: filtering, validation, transformation.

## Filtering Example

```swift
protocol GetFiltered{Name}sUseCaseContract: Sendable {
    func execute(status: {Name}Status?) async throws({Feature}Error) -> [{Name}]
}

struct GetFiltered{Name}sUseCase: GetFiltered{Name}sUseCaseContract {
    private let repository: {Name}RepositoryContract

    init(repository: {Name}RepositoryContract) {
        self.repository = repository
    }

    func execute(status: {Name}Status?) async throws({Feature}Error) -> [{Name}] {
        let items = try await repository.getAll{Name}s()

        guard let status else {
            return items
        }

        return items.filter { $0.status == status }
    }
}
```

## Validation Example

```swift
protocol Create{Name}UseCaseContract: Sendable {
    func execute(name: String, status: String) async throws({Feature}Error) -> {Name}
}

struct Create{Name}UseCase: Create{Name}UseCaseContract {
    private let repository: {Name}RepositoryContract

    init(repository: {Name}RepositoryContract) {
        self.repository = repository
    }

    func execute(name: String, status: String) async throws({Feature}Error) -> {Name} {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw {Feature}Error.emptyName
        }

        guard {Name}Status(rawValue: status) != nil else {
            throw {Feature}Error.invalidStatus
        }

        return try await repository.create{Name}(name: name, status: status)
    }
}
```

> **Note:** Validation errors should be cases in the feature's Domain Error enum (see `/repository` skill), not a separate error type.

## Filtering Tests

Test all branches: happy path, each filter case, edge cases (empty results).

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct GetFiltered{Name}sUseCaseTests {
    @Test("Returns all items when no filter is applied")
    func returnsAllItemsWhenNoFilter() async throws {
        // Given
        let items = [{Name}.stub(status: .active), {Name}.stub(status: .inactive)]
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.allResult = .success(items)
        let sut = GetFiltered{Name}sUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(status: nil)

        // Then
        #expect(value.count == 2)
    }

    @Test("Filters items by status")
    func filtersItemsByStatus() async throws {
        // Given
        let items = [
            {Name}.stub(id: 1, status: .active),
            {Name}.stub(id: 2, status: .inactive),
            {Name}.stub(id: 3, status: .active),
        ]
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.allResult = .success(items)
        let sut = GetFiltered{Name}sUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(status: .active)

        // Then
        #expect(value.count == 2)
        #expect(value.allSatisfy { $0.status == .active })
    }

    @Test("Returns empty array when no items match filter")
    func returnsEmptyArrayWhenNoMatches() async throws {
        // Given
        let items = [{Name}.stub(status: .active)]
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.allResult = .success(items)
        let sut = GetFiltered{Name}sUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(status: .inactive)

        // Then
        #expect(value.isEmpty)
    }
}
```

## Validation Tests

Test validation errors and verify repository is NOT called on validation failure.

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct Create{Name}UseCaseTests {
    @Test("Throws error for empty name")
    func throwsErrorForEmptyName() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        let sut = Create{Name}UseCase(repository: repositoryMock)

        // When / Then
        await #expect(throws: {Feature}Error.emptyName) {
            _ = try await sut.execute(name: "   ", status: "Active")
        }
    }

    @Test("Does not call repository on validation error")
    func doesNotCallRepositoryOnValidationError() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        let sut = Create{Name}UseCase(repository: repositoryMock)

        // When
        _ = try? await sut.execute(name: "", status: "Active")

        // Then
        #expect(repositoryMock.createCallCount == 0)
    }

    @Test("Creates item with valid input")
    func createsItemWithValidInput() async throws {
        // Given
        let expected = {Name}.stub()
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.createResult = .success(expected)
        let sut = Create{Name}UseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(name: "Rick", status: "Active")

        // Then
        #expect(value == expected)
        #expect(repositoryMock.createCallCount == 1)
    }
}
```
