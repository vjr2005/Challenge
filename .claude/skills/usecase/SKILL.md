---
name: usecase
description: Creates UseCases that encapsulate business logic. Use when creating use cases, implementing domain rules, validations, or coordinating multiple repositories.
---

# Skill: UseCase

Guide for creating UseCases that encapsulate business logic following Clean Architecture.

## When to use this skill

- Create a new UseCase to encapsulate a single business operation
- Add business logic that coordinates multiple repositories
- Implement domain rules and validations

## File structure

```
Features/{Feature}/
├── Sources/
│   └── Domain/
│       ├── Models/
│       │   └── {Name}.swift                    # Domain model (see /repository skill)
│       ├── Repositories/
│       │   └── {Name}RepositoryContract.swift  # Repository contract (see /repository skill)
│       └── UseCases/
│           └── Get{Name}UseCase.swift          # Contract + Implementation
└── Tests/
    ├── Domain/
    │   └── UseCases/
    │       └── Get{Name}UseCaseTests.swift     # Tests
    └── Mocks/
        └── Get{Name}UseCaseMock.swift          # Mock for testing ViewModels
```

## UseCase Pattern

### Single Responsibility

Each UseCase encapsulates **one business operation** with **exactly one public method: `execute`**.

> **CRITICAL:** A UseCase must have only the `execute` method. If you need multiple operations, create separate UseCases. For example:
> - Instead of adding `search` method to `GetCharactersUseCase`, create a separate `SearchCharactersUseCase`
> - Instead of adding `cachePolicy` parameter to `GetCharactersUseCase`, create separate `GetCharactersUseCase` (localFirst) and `RefreshCharactersUseCase` (remoteFirst)
>
> **Never add auxiliary methods** like `validate()` to existing UseCases. Each operation deserves its own UseCase.
>
> **For cache control:** Create separate UseCases for Get (localFirst) and Refresh (remoteFirst). See "Separate Get and Refresh UseCases" section below.

Naming convention:

| Operation | UseCase Name | Method | Cache Policy |
|-----------|--------------|--------|--------------|
| Get single item | `Get{Name}DetailUseCase` | `execute(identifier:)` | localFirst (implicit) |
| Refresh single item | `Refresh{Name}DetailUseCase` | `execute(identifier:)` | remoteFirst (implicit) |
| Get list | `Get{Name}sUseCase` | `execute(page:)` | localFirst (implicit) |
| Refresh list | `Refresh{Name}sUseCase` | `execute(page:)` | remoteFirst (implicit) |
| Search | `Search{Name}sUseCase` | `execute(page:, query:)` | none (always remote) |
| Create | `Create{Name}UseCase` | `execute({name}:)` | - |
| Update | `Update{Name}UseCase` | `execute({name}:)` | - |
| Delete | `Delete{Name}UseCase` | `execute(id:)` | - |
| Custom action | `{Action}{Name}UseCase` | `execute(...)` | - |

> **Note:** Use `Detail` suffix for single-item UseCases (e.g., `GetCharacterDetailUseCase`) to distinguish from list UseCases (`GetCharactersUseCase`).

### 1. Contract (Protocol)

```swift
protocol Get{Name}UseCaseContract: Sendable {
    func execute(id: Int) async throws -> {Name}
}
```

**Rules:**
- `Contract` suffix in the name
- **Internal visibility** (not public)
- Conform to `Sendable`
- Method is `async throws`
- **Only one method: `execute`** with appropriate parameters
- **Return Domain models, NOT DTOs**

### 2. Implementation

```swift
struct Get{Name}UseCase: Get{Name}UseCaseContract {
    private let repository: {Name}RepositoryContract

    init(repository: {Name}RepositoryContract) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> {Name} {
        try await repository.get{Name}(id: id)
    }
}
```

**Rules:**
- **Internal visibility** (not public)
- Inject Repository via protocol (not concrete type)
- Keep UseCases focused on single responsibility
- Business logic goes here, not in Repository

### 3. Mock (in Tests/Mocks/)

```swift
import Foundation

@testable import {AppName}{Feature}

final class Get{Name}DetailUseCaseMock: Get{Name}DetailUseCaseContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed)
    private(set) var executeCallCount = 0
    private(set) var lastRequestedIdentifier: Int?

    func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
        executeCallCount += 1
        lastRequestedIdentifier = identifier
        return try result.get()
    }
}

final class Refresh{Name}DetailUseCaseMock: Refresh{Name}DetailUseCaseContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed)
    private(set) var executeCallCount = 0
    private(set) var lastRequestedIdentifier: Int?

    func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
        executeCallCount += 1
        lastRequestedIdentifier = identifier
        return try result.get()
    }
}
```

**Rules:**
- `Mock` suffix in the name
- Located in `Tests/Mocks/`
- **Requires `@testable import`** to access internal types
- `@unchecked Sendable` if it has mutable state
- Call tracking properties (no cachePolicy tracking - it's encapsulated)
- Default result should be `.failure` to catch unconfigured mocks

---

## UseCase Types

> **Note:** The following examples use `Character` as a concrete example. Replace with your domain model name.

### Separate Get and Refresh UseCases

Instead of using a `cachePolicy` parameter, create separate UseCases for different cache behaviors. This improves:
- **Single Responsibility**: Each UseCase has one clear purpose
- **Readability**: UseCase name expresses intent (`GetCharacterDetail` vs `RefreshCharacterDetail`)
- **Encapsulation**: ViewModels don't need to know about cache policies

```swift
// GetCharacterDetailUseCase - uses localFirst cache policy (implicit)
protocol GetCharacterDetailUseCaseContract: Sendable {
    func execute(identifier: Int) async throws(CharacterError) -> Character
}

struct GetCharacterDetailUseCase: GetCharacterDetailUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(identifier: Int) async throws(CharacterError) -> Character {
        try await repository.getCharacterDetail(identifier: identifier, cachePolicy: .localFirst)
    }
}

// RefreshCharacterDetailUseCase - uses remoteFirst cache policy (implicit)
protocol RefreshCharacterDetailUseCaseContract: Sendable {
    func execute(identifier: Int) async throws(CharacterError) -> Character
}

struct RefreshCharacterDetailUseCase: RefreshCharacterDetailUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(identifier: Int) async throws(CharacterError) -> Character {
        try await repository.getCharacterDetail(identifier: identifier, cachePolicy: .remoteFirst)
    }
}
```

### UseCase with Business Logic

For operations that include domain rules:

```swift
// Example: GetFilteredCharactersUseCase
protocol GetFilteredCharactersUseCaseContract: Sendable {
    func execute(status: CharacterStatus?) async throws -> [Character]
}

struct GetFilteredCharactersUseCase: GetFilteredCharactersUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(status: CharacterStatus?) async throws -> [Character] {
        let characters = try await repository.getAllCharacters()

        // Business logic: filter by status if provided
        guard let status else {
            return characters
        }

        return characters.filter { $0.status == status }
    }
}
```

### UseCase with Multiple Repositories

For operations that coordinate multiple data sources:

```swift
// Example: GetCharacterWithEpisodesUseCase
protocol GetCharacterWithEpisodesUseCaseContract: Sendable {
    func execute(id: Int) async throws -> CharacterWithEpisodes
}

struct GetCharacterWithEpisodesUseCase: GetCharacterWithEpisodesUseCaseContract {
    private let characterRepository: CharacterRepositoryContract
    private let episodeRepository: EpisodeRepositoryContract

    init(
        characterRepository: CharacterRepositoryContract,
        episodeRepository: EpisodeRepositoryContract
    ) {
        self.characterRepository = characterRepository
        self.episodeRepository = episodeRepository
    }

    func execute(id: Int) async throws -> CharacterWithEpisodes {
        let character = try await characterRepository.getCharacter(id: id)
        let episodes = try await episodeRepository.getEpisodes(ids: character.episodeIds)

        return CharacterWithEpisodes(
            character: character,
            episodes: episodes
        )
    }
}
```

### Get and Refresh UseCases for Lists

The same pattern applies to list operations:

```swift
// GetCharactersUseCase - uses localFirst cache policy (implicit)
protocol GetCharactersUseCaseContract: Sendable {
    func execute(page: Int) async throws(CharacterError) -> CharactersPage
}

struct GetCharactersUseCase: GetCharactersUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(page: Int) async throws(CharacterError) -> CharactersPage {
        try await repository.getCharacters(page: page, cachePolicy: .localFirst)
    }
}

// RefreshCharactersUseCase - uses remoteFirst cache policy (implicit)
protocol RefreshCharactersUseCaseContract: Sendable {
    func execute(page: Int) async throws(CharacterError) -> CharactersPage
}

struct RefreshCharactersUseCase: RefreshCharactersUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(page: Int) async throws(CharacterError) -> CharactersPage {
        try await repository.getCharacters(page: page, cachePolicy: .remoteFirst)
    }
}
```

**Usage in ViewModels:**

```swift
// Load with localFirst (default behavior)
let page = try await getCharactersUseCase.execute(page: 1)

// Refresh with remoteFirst
let page = try await refreshCharactersUseCase.execute(page: 1)
```

> **Note:** The cache policy is encapsulated in the UseCase, not exposed to ViewModels. This provides:
> - Clear intent through UseCase name (Get vs Refresh)
> - ViewModels don't need to know about cache policies
> - Each UseCase has a single responsibility

### UseCase for Search (No Cache)

Search operations typically bypass cache and always go to remote:

```swift
// Example: SearchCharactersUseCase (always remote, no cachePolicy parameter)
protocol SearchCharactersUseCaseContract: Sendable {
    func execute(page: Int, query: String) async throws(CharacterError) -> CharactersPage
}

struct SearchCharactersUseCase: SearchCharactersUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(page: Int, query: String) async throws(CharacterError) -> CharactersPage {
        try await repository.searchCharacters(page: page, query: query)
    }
}
```

> **Note:** `SearchCharactersUseCase` does NOT have a `cachePolicy` parameter because search results are always fetched from remote.

### UseCase with Validation

For operations that validate input:

```swift
// Example: CreateCharacterUseCase
enum CreateCharacterError: Error {
    case emptyName
    case invalidStatus
}

protocol CreateCharacterUseCaseContract: Sendable {
    func execute(name: String, status: String) async throws -> Character
}

struct CreateCharacterUseCase: CreateCharacterUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(name: String, status: String) async throws -> Character {
        // Validation logic
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw CreateCharacterError.emptyName
        }

        guard CharacterStatus(rawValue: status) != nil else {
            throw CreateCharacterError.invalidStatus
        }

        return try await repository.createCharacter(name: name, status: status)
    }
}
```

---

## Testing

> **Note:** The following test examples use `Character` as a concrete example. Replace with your domain model name.

### Get UseCase Test

```swift
import ChallengeCore
import Foundation
import Testing

@testable import {AppName}{Feature}

struct Get{Name}DetailUseCaseTests {
    @Test("Execute returns model from repository")
    func executeReturnsModel() async throws {
        // Given
        let expected = {Name}.stub()
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .success(expected)
        let sut = Get{Name}DetailUseCase(repository: repositoryMock)

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
        let sut = Get{Name}DetailUseCase(repository: repositoryMock)

        // When
        _ = try await sut.execute(identifier: 42)

        // Then
        #expect(repositoryMock.get{Name}DetailCallCount == 1)
        #expect(repositoryMock.lastRequestedIdentifier == 42)
        #expect(repositoryMock.last{Name}DetailCachePolicy == .localFirst)
    }

    @Test("Execute propagates repository error")
    func executePropagatesError() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .failure(.loadFailed)
        let sut = Get{Name}DetailUseCase(repository: repositoryMock)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.execute(identifier: 1)
        }
    }
}
```

### Refresh UseCase Test

```swift
import ChallengeCore
import Foundation
import Testing

@testable import {AppName}{Feature}

struct Refresh{Name}DetailUseCaseTests {
    @Test("Execute returns model from repository")
    func executeReturnsModel() async throws {
        // Given
        let expected = {Name}.stub()
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .success(expected)
        let sut = Refresh{Name}DetailUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(identifier: 1)

        // Then
        #expect(value == expected)
    }

    @Test("Execute calls repository with correct identifier and remoteFirst cache policy")
    func executeCallsRepositoryWithRemoteFirst() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .success(.stub())
        let sut = Refresh{Name}DetailUseCase(repository: repositoryMock)

        // When
        _ = try await sut.execute(identifier: 42)

        // Then
        #expect(repositoryMock.get{Name}DetailCallCount == 1)
        #expect(repositoryMock.lastRequestedIdentifier == 42)
        #expect(repositoryMock.last{Name}DetailCachePolicy == .remoteFirst)
    }

    @Test("Execute propagates repository error")
    func executePropagatesError() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .failure(.loadFailed)
        let sut = Refresh{Name}DetailUseCase(repository: repositoryMock)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.execute(identifier: 1)
        }
    }
}
```

### UseCase with Business Logic Test

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct GetFilteredCharactersUseCaseTests {
    @Test("Returns all characters when no filter is applied")
    func returnsAllCharactersWhenNoFilter() async throws {
        // Given
        let characters = [
            Character.stub(status: .alive),
            Character.stub(status: .dead),
        ]
        let repositoryMock = CharacterRepositoryMock()
        repositoryMock.allResult = .success(characters)
        let sut = GetFilteredCharactersUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(status: nil)

        // Then
        #expect(value.count == 2)
    }

    @Test("Filters characters by status")
    func filtersCharactersByStatus() async throws {
        // Given
        let characters = [
            Character.stub(id: 1, status: .alive),
            Character.stub(id: 2, status: .dead),
            Character.stub(id: 3, status: .alive),
        ]
        let repositoryMock = CharacterRepositoryMock()
        repositoryMock.allResult = .success(characters)
        let sut = GetFilteredCharactersUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(status: .alive)

        // Then
        #expect(value.count == 2)
        #expect(value.allSatisfy { $0.status == .alive })
    }

    @Test("Returns empty array when no characters match filter")
    func returnsEmptyArrayWhenNoMatches() async throws {
        // Given
        let characters = [Character.stub(status: .alive)]
        let repositoryMock = CharacterRepositoryMock()
        repositoryMock.allResult = .success(characters)
        let sut = GetFilteredCharactersUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(status: .dead)

        // Then
        #expect(value.isEmpty)
    }
}
```

### UseCase with Validation Test

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct CreateCharacterUseCaseTests {
    @Test("Throws error for empty name")
    func throwsErrorForEmptyName() async throws {
        // Given
        let repositoryMock = CharacterRepositoryMock()
        let sut = CreateCharacterUseCase(repository: repositoryMock)

        // When / Then
        await #expect(throws: CreateCharacterError.emptyName) {
            _ = try await sut.execute(name: "   ", status: "Alive")
        }
    }

    @Test("Throws error for invalid status")
    func throwsErrorForInvalidStatus() async throws {
        // Given
        let repositoryMock = CharacterRepositoryMock()
        let sut = CreateCharacterUseCase(repository: repositoryMock)

        // When / Then
        await #expect(throws: CreateCharacterError.invalidStatus) {
            _ = try await sut.execute(name: "Rick", status: "Invalid")
        }
    }

    @Test("Creates character with valid input")
    func createsCharacterWithValidInput() async throws {
        // Given
        let expected = Character.stub()
        let repositoryMock = CharacterRepositoryMock()
        repositoryMock.createResult = .success(expected)
        let sut = CreateCharacterUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(name: "Rick", status: "Alive")

        // Then
        #expect(value == expected)
        #expect(repositoryMock.createCallCount == 1)
    }

    @Test("Does not call repository on validation error")
    func doesNotCallRepositoryOnValidationError() async throws {
        // Given
        let repositoryMock = CharacterRepositoryMock()
        let sut = CreateCharacterUseCase(repository: repositoryMock)

        // When
        _ = try? await sut.execute(name: "", status: "Alive")

        // Then
        #expect(repositoryMock.createCallCount == 0)
    }
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Contract | internal | `Sources/Domain/UseCases/` |
| Implementation | internal | `Sources/Domain/UseCases/` |
| Mock | internal | `Tests/Mocks/` |

---

## Checklist

### Get UseCase (localFirst)

- [ ] Create Contract with `execute` method and Sendable conformance
- [ ] Create Implementation injecting Repository via protocol
- [ ] Use `cachePolicy: .localFirst` internally (not exposed)
- [ ] Create Mock in Tests/Mocks/ with call tracking
- [ ] Create tests verifying delegation and error propagation
- [ ] Create test verifying repository is called with `.localFirst`
- [ ] Run tests

### Refresh UseCase (remoteFirst)

- [ ] Create Contract with `execute` method and Sendable conformance
- [ ] Create Implementation injecting Repository via protocol
- [ ] Use `cachePolicy: .remoteFirst` internally (not exposed)
- [ ] Create Mock in Tests/Mocks/ with call tracking
- [ ] Create tests verifying delegation and error propagation
- [ ] Create test verifying repository is called with `.remoteFirst`
- [ ] Run tests

### Search UseCase (No Cache)

- [ ] Create Contract with `execute` method (page, query parameters)
- [ ] Create Implementation injecting Repository via protocol
- [ ] Create Mock in Tests/Mocks/ with call tracking
- [ ] Create tests verifying delegation and error propagation
- [ ] Run tests

### UseCase with Business Logic

- [ ] Create Contract with appropriate parameters
- [ ] Create Implementation with business logic
- [ ] Create custom Error enum if needed
- [ ] Create Mock in Tests/Mocks/ with call tracking
- [ ] Create tests for all business logic branches
- [ ] Create tests for edge cases (empty results, validation errors)
- [ ] Run tests

### UseCase with Multiple Repositories

- [ ] Create Contract with appropriate parameters
- [ ] Create Implementation injecting all required Repositories
- [ ] Create Mock in Tests/Mocks/ with call tracking
- [ ] Create tests verifying coordination between repositories
- [ ] Create tests for error handling from each repository
- [ ] Run tests
