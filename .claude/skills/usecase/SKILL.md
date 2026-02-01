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
>
> **Never add auxiliary methods** like `validate()` to existing UseCases. Each operation deserves its own UseCase.
>
> **For cache control:** Use `CachePolicy` parameter instead of separate UseCases. See "UseCase with CachePolicy" section below.

Naming convention:

| Operation | UseCase Name | Method |
|-----------|--------------|--------|
| Get single item | `Get{Name}UseCase` | `execute(id:, cachePolicy:)` |
| Get list | `Get{Name}sUseCase` | `execute(page:, cachePolicy:)` |
| Search | `Search{Name}sUseCase` | `execute(page:, query:)` |
| Create | `Create{Name}UseCase` | `execute({name}:)` |
| Update | `Update{Name}UseCase` | `execute({name}:)` |
| Delete | `Delete{Name}UseCase` | `execute(id:)` |
| Custom action | `{Action}{Name}UseCase` | `execute(...)` |

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

final class Get{Name}UseCaseMock: Get{Name}UseCaseContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed)
    private(set) var executeCallCount = 0
    private(set) var lastRequestedId: Int?
    private(set) var lastCachePolicy: CachePolicy?

    func execute(id: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        executeCallCount += 1
        lastRequestedId = id
        lastCachePolicy = cachePolicy
        return try result.get()
    }
}
```

**Rules:**
- `Mock` suffix in the name
- Located in `Tests/Mocks/`
- **Requires `@testable import`** to access internal types
- `@unchecked Sendable` if it has mutable state
- Call tracking properties
- Default result should be `.failure` to catch unconfigured mocks

---

## UseCase Types

> **Note:** The following examples use `Character` as a concrete example. Replace with your domain model name.

### Simple UseCase (Pass-through with CachePolicy)

For simple operations that just delegate to repository with cache control:

```swift
// Example: GetCharacterUseCase
protocol GetCharacterUseCaseContract: Sendable {
    func execute(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
}

// Default extension for common case
extension GetCharacterUseCaseContract {
    func execute(identifier: Int) async throws(CharacterError) -> Character {
        try await execute(identifier: identifier, cachePolicy: .localFirst)
    }
}

struct GetCharacterUseCase: GetCharacterUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
        try await repository.getCharacter(identifier: identifier, cachePolicy: cachePolicy)
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

### UseCase with CachePolicy

For operations that support configurable cache behavior, use `CachePolicy` parameter with a default extension:

```swift
// Example: GetCharacterUseCase with CachePolicy
protocol GetCharacterUseCaseContract: Sendable {
    func execute(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
}

// Default extension for backward compatibility
extension GetCharacterUseCaseContract {
    func execute(identifier: Int) async throws(CharacterError) -> Character {
        try await execute(identifier: identifier, cachePolicy: .localFirst)
    }
}

struct GetCharacterUseCase: GetCharacterUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
        try await repository.getCharacter(identifier: identifier, cachePolicy: cachePolicy)
    }
}
```

**Usage in ViewModels:**

```swift
// Load with default (localFirst)
let character = try await getCharacterUseCase.execute(identifier: id)

// Refresh with remoteFirst
let character = try await getCharacterUseCase.execute(identifier: id, cachePolicy: .remoteFirst)
```

> **Note:** The default extension is at the **UseCase level**, not at the Repository level. This provides:
> - Clean API for callers (no need to specify cachePolicy for common case)
> - Explicit control when needed (refresh operations)
> - Repository contract remains explicit about its parameters

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

### Simple UseCase Test (with CachePolicy)

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct Get{Name}UseCaseTests {
    @Test("Returns model from repository")
    func returnsModelFromRepository() async throws {
        // Given
        let expected = {Name}.stub()
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .success(expected)
        let sut = Get{Name}UseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(id: 1, cachePolicy: .localFirst)

        // Then
        #expect(value == expected)
    }

    @Test("Calls repository with correct id and cachePolicy")
    func callsRepositoryWithCorrectIdAndCachePolicy() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .success(.stub())
        let sut = Get{Name}UseCase(repository: repositoryMock)

        // When
        _ = try await sut.execute(id: 42, cachePolicy: .remoteFirst)

        // Then
        #expect(repositoryMock.getCallCount == 1)
        #expect(repositoryMock.lastRequestedId == 42)
        #expect(repositoryMock.lastCachePolicy == .remoteFirst)
    }

    @Test("Propagates repository error")
    func propagatesRepositoryError() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .failure(.loadFailed)
        let sut = Get{Name}UseCase(repository: repositoryMock)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.execute(id: 1, cachePolicy: .localFirst)
        }
    }

    @Test("Default cachePolicy uses localFirst")
    func defaultCachePolicyUsesLocalFirst() async throws {
        // Given
        let repositoryMock = {Name}RepositoryMock()
        repositoryMock.result = .success(.stub())
        let sut = Get{Name}UseCase(repository: repositoryMock)

        // When
        _ = try await sut.execute(id: 1) // Uses default extension

        // Then
        #expect(repositoryMock.lastCachePolicy == .localFirst)
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

### Simple UseCase with CachePolicy

- [ ] Create Contract with `execute` method, `cachePolicy` parameter, and Sendable conformance
- [ ] Create default extension for `execute` without cachePolicy (defaults to `.localFirst`)
- [ ] Create Implementation injecting Repository via protocol
- [ ] Create Mock in Tests/Mocks/ with call tracking (including cachePolicy)
- [ ] Create tests verifying delegation and error propagation
- [ ] Create test verifying default cachePolicy uses `.localFirst`
- [ ] Run tests

### Search UseCase (No CachePolicy)

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
