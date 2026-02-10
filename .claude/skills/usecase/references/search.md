# Search UseCase

Search bypasses cache — always remote, no `cachePolicy` parameter.

## Implementation

```swift
protocol Search{Name}sPageUseCaseContract: Sendable {
    func execute(page: Int, filter: {Name}Filter) async throws({Feature}Error) -> {Name}sPage
}

struct Search{Name}sPageUseCase: Search{Name}sPageUseCaseContract {
    private let repository: {Name}sPageRepositoryContract

    init(repository: {Name}sPageRepositoryContract) {
        self.repository = repository
    }

    func execute(page: Int, filter: {Name}Filter) async throws({Feature}Error) -> {Name}sPage {
        try await repository.search{Name}sPage(page: page, filter: filter)
    }
}
```

## Mock

```swift
@testable import {AppName}{Feature}

final class Search{Name}sPageUseCaseMock: Search{Name}sPageUseCaseContract, @unchecked Sendable {
    var result: Result<{Name}sPage, {Feature}Error> = .failure(.loadFailed())
    private(set) var executeCallCount = 0
    private(set) var lastRequestedPage: Int?
    private(set) var lastRequestedFilter: {Name}Filter?

    @MainActor init() {}

    func execute(page: Int, filter: {Name}Filter) async throws({Feature}Error) -> {Name}sPage {
        executeCallCount += 1
        lastRequestedPage = page
        lastRequestedFilter = filter
        return try result.get()
    }
}
```

## Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct Search{Name}sPageUseCaseTests {
    @Test("Execute returns page from repository")
    func executeReturnsPage() async throws {
        // Given
        let expected = {Name}sPage.stub()
        let repositoryMock = {Name}sPageRepositoryMock()
        repositoryMock.searchResult = .success(expected)
        let sut = Search{Name}sPageUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(page: 1, filter: .stub())

        // Then
        #expect(value == expected)
    }

    @Test("Execute calls repository with correct parameters")
    func executeCallsRepositoryWithCorrectParameters() async throws {
        // Given
        let filter = {Name}Filter.stub(name: "Rick")
        let repositoryMock = {Name}sPageRepositoryMock()
        repositoryMock.searchResult = .success(.stub())
        let sut = Search{Name}sPageUseCase(repository: repositoryMock)

        // When
        _ = try await sut.execute(page: 2, filter: filter)

        // Then
        #expect(repositoryMock.search{Name}sPageCallCount == 1)
        #expect(repositoryMock.lastRequestedPage == 2)
        #expect(repositoryMock.lastRequestedFilter == filter)
    }

    @Test("Execute propagates repository error")
    func executePropagatesError() async throws {
        // Given
        let repositoryMock = {Name}sPageRepositoryMock()
        repositoryMock.searchResult = .failure(.loadFailed())
        let sut = Search{Name}sPageUseCase(repository: repositoryMock)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed()) {
            _ = try await sut.execute(page: 1, filter: .stub())
        }
    }
}
```
