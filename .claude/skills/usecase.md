# Skill: UseCase

Guide for creating UseCases that encapsulate business logic following Clean Architecture.

## When to use this skill

- Create a new UseCase to encapsulate a single business operation
- Add business logic that coordinates multiple repositories
- Implement domain rules and validations

## File structure

```
Libraries/Features/{FeatureName}/
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

Each UseCase encapsulates **one business operation**. Naming convention:

| Operation | UseCase Name | Method |
|-----------|--------------|--------|
| Get single item | `Get{Name}UseCase` | `execute(id:)` |
| Get list | `GetAll{Name}sUseCase` | `execute()` |
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
- Method name is always `execute` with appropriate parameters
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

@testable import Challenge{FeatureName}

final class Get{Name}UseCaseMock: Get{Name}UseCaseContract, @unchecked Sendable {
    var result: Result<{Name}, Error> = .failure(NotConfiguredError.notConfigured)
    private(set) var executeCallCount = 0
    private(set) var lastRequestedId: Int?

    func execute(id: Int) async throws -> {Name} {
        executeCallCount += 1
        lastRequestedId = id
        return try result.get()
    }
}

private enum NotConfiguredError: Error {
    case notConfigured
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

### Simple UseCase (Pass-through)

For simple operations that just delegate to repository:

```swift
// Example: GetCharacterUseCase
protocol GetCharacterUseCaseContract: Sendable {
    func execute(id: Int) async throws -> Character
}

struct GetCharacterUseCase: GetCharacterUseCaseContract {
    private let repository: CharacterRepositoryContract

    init(repository: CharacterRepositoryContract) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Character {
        try await repository.getCharacter(id: id)
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

### Simple UseCase Test

```swift
import Foundation
import Testing

@testable import Challenge{FeatureName}

struct Get{Name}UseCaseTests {
    @Test
    func returnsModelFromRepository() async throws {
        // Given
        let expected = {Name}.stub()
        let repository = {Name}RepositoryMock()
        repository.result = .success(expected)
        let sut = Get{Name}UseCase(repository: repository)

        // When
        let value = try await sut.execute(id: 1)

        // Then
        #expect(value == expected)
    }

    @Test
    func callsRepositoryWithCorrectId() async throws {
        // Given
        let repository = {Name}RepositoryMock()
        repository.result = .success(.stub())
        let sut = Get{Name}UseCase(repository: repository)

        // When
        _ = try await sut.execute(id: 42)

        // Then
        #expect(repository.getCallCount == 1)
        #expect(repository.lastRequestedId == 42)
    }

    @Test
    func propagatesRepositoryError() async throws {
        // Given
        let repository = {Name}RepositoryMock()
        repository.result = .failure(TestError.network)
        let sut = Get{Name}UseCase(repository: repository)

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.execute(id: 1)
        }
    }
}

private enum TestError: Error {
    case network
}
```

### UseCase with Business Logic Test

```swift
import Foundation
import Testing

@testable import Challenge{FeatureName}

struct GetFilteredCharactersUseCaseTests {
    @Test
    func returnsAllCharactersWhenNoFilter() async throws {
        // Given
        let characters = [
            Character.stub(status: .alive),
            Character.stub(status: .dead),
        ]
        let repository = CharacterRepositoryMock()
        repository.allResult = .success(characters)
        let sut = GetFilteredCharactersUseCase(repository: repository)

        // When
        let value = try await sut.execute(status: nil)

        // Then
        #expect(value.count == 2)
    }

    @Test
    func filtersCharactersByStatus() async throws {
        // Given
        let characters = [
            Character.stub(id: 1, status: .alive),
            Character.stub(id: 2, status: .dead),
            Character.stub(id: 3, status: .alive),
        ]
        let repository = CharacterRepositoryMock()
        repository.allResult = .success(characters)
        let sut = GetFilteredCharactersUseCase(repository: repository)

        // When
        let value = try await sut.execute(status: .alive)

        // Then
        #expect(value.count == 2)
        #expect(value.allSatisfy { $0.status == .alive })
    }

    @Test
    func returnsEmptyArrayWhenNoMatches() async throws {
        // Given
        let characters = [Character.stub(status: .alive)]
        let repository = CharacterRepositoryMock()
        repository.allResult = .success(characters)
        let sut = GetFilteredCharactersUseCase(repository: repository)

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

@testable import Challenge{FeatureName}

struct CreateCharacterUseCaseTests {
    @Test
    func throwsErrorForEmptyName() async throws {
        // Given
        let repository = CharacterRepositoryMock()
        let sut = CreateCharacterUseCase(repository: repository)

        // When / Then
        await #expect(throws: CreateCharacterError.emptyName) {
            _ = try await sut.execute(name: "   ", status: "Alive")
        }
    }

    @Test
    func throwsErrorForInvalidStatus() async throws {
        // Given
        let repository = CharacterRepositoryMock()
        let sut = CreateCharacterUseCase(repository: repository)

        // When / Then
        await #expect(throws: CreateCharacterError.invalidStatus) {
            _ = try await sut.execute(name: "Rick", status: "Invalid")
        }
    }

    @Test
    func createsCharacterWithValidInput() async throws {
        // Given
        let expected = Character.stub()
        let repository = CharacterRepositoryMock()
        repository.createResult = .success(expected)
        let sut = CreateCharacterUseCase(repository: repository)

        // When
        let value = try await sut.execute(name: "Rick", status: "Alive")

        // Then
        #expect(value == expected)
        #expect(repository.createCallCount == 1)
    }

    @Test
    func doesNotCallRepositoryOnValidationError() async throws {
        // Given
        let repository = CharacterRepositoryMock()
        let sut = CreateCharacterUseCase(repository: repository)

        // When
        _ = try? await sut.execute(name: "", status: "Alive")

        // Then
        #expect(repository.createCallCount == 0)
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

### Simple UseCase

- [ ] Create Contract with `execute` method and Sendable conformance
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
