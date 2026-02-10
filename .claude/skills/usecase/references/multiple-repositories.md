# Multiple Repositories UseCase

For operations that coordinate data from 2+ repositories.

## Implementation

```swift
protocol Get{Name}With{Related}sUseCaseContract: Sendable {
    func execute(identifier: Int) async throws({Feature}Error) -> {Name}With{Related}s
}

struct Get{Name}With{Related}sUseCase: Get{Name}With{Related}sUseCaseContract {
    private let {name}Repository: {Name}RepositoryContract
    private let {related}Repository: {Related}RepositoryContract

    init(
        {name}Repository: {Name}RepositoryContract,
        {related}Repository: {Related}RepositoryContract
    ) {
        self.{name}Repository = {name}Repository
        self.{related}Repository = {related}Repository
    }

    func execute(identifier: Int) async throws({Feature}Error) -> {Name}With{Related}s {
        let item = try await {name}Repository.get{Name}(identifier: identifier, cachePolicy: .localFirst)
        let related = try await {related}Repository.get{Related}s(identifiers: item.{related}Identifiers, cachePolicy: .localFirst)

        return {Name}With{Related}s(
            {name}: item,
            {related}s: related
        )
    }
}
```

## Mock

```swift
@testable import {AppName}{Feature}

final class Get{Name}With{Related}sUseCaseMock: Get{Name}With{Related}sUseCaseContract, @unchecked Sendable {
    var result: Result<{Name}With{Related}s, {Feature}Error> = .failure(.loadFailed())
    private(set) var executeCallCount = 0
    private(set) var lastRequestedIdentifier: Int?

    @MainActor init() {}

    func execute(identifier: Int) async throws({Feature}Error) -> {Name}With{Related}s {
        executeCallCount += 1
        lastRequestedIdentifier = identifier
        return try result.get()
    }
}
```

## Tests

Test coordination and error propagation from each repository.

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct Get{Name}With{Related}sUseCaseTests {
    @Test("Returns combined model from both repositories")
    func returnsCombinedModel() async throws {
        // Given
        let item = {Name}.stub({related}Identifiers: [1, 2])
        let related = [{Related}.stub(id: 1), {Related}.stub(id: 2)]
        let {name}RepositoryMock = {Name}RepositoryMock()
        {name}RepositoryMock.result = .success(item)
        let {related}RepositoryMock = {Related}RepositoryMock()
        {related}RepositoryMock.result = .success(related)
        let sut = Get{Name}With{Related}sUseCase(
            {name}Repository: {name}RepositoryMock,
            {related}Repository: {related}RepositoryMock
        )

        // When
        let value = try await sut.execute(identifier: 1)

        // Then
        #expect(value.{name} == item)
        #expect(value.{related}s == related)
    }

    @Test("Propagates error from first repository")
    func propagatesFirstRepositoryError() async throws {
        // Given
        let {name}RepositoryMock = {Name}RepositoryMock()
        {name}RepositoryMock.result = .failure(.loadFailed())
        let {related}RepositoryMock = {Related}RepositoryMock()
        let sut = Get{Name}With{Related}sUseCase(
            {name}Repository: {name}RepositoryMock,
            {related}Repository: {related}RepositoryMock
        )

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed()) {
            _ = try await sut.execute(identifier: 1)
        }
    }

    @Test("Propagates error from second repository")
    func propagatesSecondRepositoryError() async throws {
        // Given
        let {name}RepositoryMock = {Name}RepositoryMock()
        {name}RepositoryMock.result = .success(.stub())
        let {related}RepositoryMock = {Related}RepositoryMock()
        {related}RepositoryMock.result = .failure(.loadFailed())
        let sut = Get{Name}With{Related}sUseCase(
            {name}Repository: {name}RepositoryMock,
            {related}Repository: {related}RepositoryMock
        )

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed()) {
            _ = try await sut.execute(identifier: 1)
        }
    }
}
```
