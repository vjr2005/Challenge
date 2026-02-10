# Get & Refresh UseCases

Separate UseCases for different cache behaviors instead of exposing `cachePolicy` parameter.

## Get UseCase (localFirst)

```swift
protocol Get{Name}UseCaseContract: Sendable {
    func execute(identifier: Int) async throws({Feature}Error) -> {Name}
}

struct Get{Name}UseCase: Get{Name}UseCaseContract {
    private let repository: {Name}RepositoryContract

    init(repository: {Name}RepositoryContract) {
        self.repository = repository
    }

    func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
        try await repository.get{Name}(identifier: identifier, cachePolicy: .localFirst)
    }
}
```

## Refresh UseCase (remoteFirst)

```swift
protocol Refresh{Name}UseCaseContract: Sendable {
    func execute(identifier: Int) async throws({Feature}Error) -> {Name}
}

struct Refresh{Name}UseCase: Refresh{Name}UseCaseContract {
    private let repository: {Name}RepositoryContract

    init(repository: {Name}RepositoryContract) {
        self.repository = repository
    }

    func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
        try await repository.get{Name}(identifier: identifier, cachePolicy: .remoteFirst)
    }
}
```

## List Variants

Same pattern with `page: Int` parameter:

```swift
// GetCharactersPageUseCase
protocol Get{Name}sPageUseCaseContract: Sendable {
    func execute(page: Int) async throws({Feature}Error) -> {Name}sPage
}

struct Get{Name}sPageUseCase: Get{Name}sPageUseCaseContract {
    private let repository: {Name}sPageRepositoryContract

    init(repository: {Name}sPageRepositoryContract) {
        self.repository = repository
    }

    func execute(page: Int) async throws({Feature}Error) -> {Name}sPage {
        try await repository.get{Name}sPage(page: page, cachePolicy: .localFirst)
    }
}

// RefreshCharactersPageUseCase
protocol Refresh{Name}sPageUseCaseContract: Sendable {
    func execute(page: Int) async throws({Feature}Error) -> {Name}sPage
}

struct Refresh{Name}sPageUseCase: Refresh{Name}sPageUseCaseContract {
    private let repository: {Name}sPageRepositoryContract

    init(repository: {Name}sPageRepositoryContract) {
        self.repository = repository
    }

    func execute(page: Int) async throws({Feature}Error) -> {Name}sPage {
        try await repository.get{Name}sPage(page: page, cachePolicy: .remoteFirst)
    }
}
```

## Mocks

```swift
@testable import {AppName}{Feature}

final class Get{Name}UseCaseMock: Get{Name}UseCaseContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
    private(set) var executeCallCount = 0
    private(set) var lastRequestedIdentifier: Int?

    @MainActor init() {}

    func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
        executeCallCount += 1
        lastRequestedIdentifier = identifier
        return try result.get()
    }
}

final class Refresh{Name}UseCaseMock: Refresh{Name}UseCaseContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
    private(set) var executeCallCount = 0
    private(set) var lastRequestedIdentifier: Int?

    @MainActor init() {}

    func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
        executeCallCount += 1
        lastRequestedIdentifier = identifier
        return try result.get()
    }
}
```

## Tests

```swift
import ChallengeCore
import Foundation
import Testing

@testable import {AppName}{Feature}

struct Get{Name}UseCaseTests {
    @Test("Execute returns model from repository")
    func executeReturnsModel() async throws {
        // Given
        let expected = {Name}.stub()
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .success(expected)
        let sut = Get{Name}UseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(identifier: 1)

        // Then
        #expect(value == expected)
    }

    @Test("Execute calls repository with correct identifier and localFirst cache policy")
    func executeCallsRepositoryWithLocalFirst() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .success(.stub())
        let sut = Get{Name}UseCase(repository: repositoryMock)

        // When
        _ = try await sut.execute(identifier: 42)

        // Then
        #expect(repositoryMock.get{Name}CallCount == 1)
        #expect(repositoryMock.lastRequestedIdentifier == 42)
        #expect(repositoryMock.lastCachePolicy == .localFirst)
    }

    @Test("Execute propagates repository error")
    func executePropagatesError() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .failure(.loadFailed())
        let sut = Get{Name}UseCase(repository: repositoryMock)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed()) {
            _ = try await sut.execute(identifier: 1)
        }
    }
}
```

For Refresh, replace `localFirst` with `remoteFirst` in test name and assertion.
