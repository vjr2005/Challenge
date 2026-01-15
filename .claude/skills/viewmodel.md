# Skill: ViewModel

Guide for creating ViewModels that manage state and coordinate between Views and UseCases.

## When to use this skill

- Create a new ViewModel for a feature
- Add state management with ViewState pattern
- Create ViewModel tests

## File structure

```
Libraries/Features/{FeatureName}/
├── Sources/
│   └── Presentation/
│       └── ViewModels/
│           ├── {Name}ViewState.swift             # ViewState enum
│           └── {Name}ViewModel.swift             # ViewModel
└── Tests/
    └── Presentation/
        └── ViewModels/
            └── {Name}ViewModelTests.swift        # Tests
```

---

## ViewState Pattern

Use an enum to represent all possible states of a view:

```swift
enum {Name}ViewState {
    case idle
    case loading
    case loaded({Name})
    case error(Error)
}
```

**Rules:**
- **Internal visibility** (not public)
- One state enum per ViewModel
- `idle` is the initial state
- `loaded` contains the data
- `error` contains the Error

### For lists:

```swift
enum {Name}ListViewState {
    case idle
    case loading
    case loaded([{Name}])
    case empty
    case error(Error)
}
```

---

## ViewModel Pattern

```swift
import SwiftUI

@MainActor
@Observable
final class {Name}ViewModel {
    private(set) var state: {Name}ViewState = .idle

    private let get{Name}UseCase: Get{Name}UseCaseContract
    private let router: {Feature}Router?

    init(
        get{Name}UseCase: Get{Name}UseCaseContract,
        router: {Feature}Router? = nil
    ) {
        self.get{Name}UseCase = get{Name}UseCase
        self.router = router
    }

    func load(id: Int) async {
        state = .loading
        do {
            let result = try await get{Name}UseCase.execute(id: id)
            state = .loaded(result)
        } catch {
            state = .error(error)
        }
    }
}
```

**Rules:**
- `@MainActor` for UI thread safety
- `@Observable` for SwiftUI integration (iOS 17+)
- `final class` to prevent subclassing
- **Internal visibility** (not public)
- Inject UseCases via **protocol (contract)**
- Router is **optional** (nil when not navigating) - see `/router` skill
- State is `private(set)` - only ViewModel mutates it

---

## Testing

### ViewModel Tests

```swift
import Foundation
import Testing

@testable import Challenge{FeatureName}

@MainActor
struct {Name}ViewModelTests {
    @Test
    func initialStateIsIdle() {
        // Given
        let useCase = Get{Name}UseCaseMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCase)

        // Then
        guard case .idle = sut.state else {
            Issue.record("Expected idle state")
            return
        }
    }

    @Test
    func loadSetsLoadedStateOnSuccess() async {
        // Given
        let expected = {Name}.stub()
        let useCase = Get{Name}UseCaseMock()
        useCase.result = .success(expected)
        let sut = {Name}ViewModel(get{Name}UseCase: useCase)

        // When
        await sut.load(id: 1)

        // Then
        guard case .loaded(let value) = sut.state else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(value == expected)
    }

    @Test
    func loadSetsErrorStateOnFailure() async {
        // Given
        let useCase = Get{Name}UseCaseMock()
        useCase.result = .failure(TestError.network)
        let sut = {Name}ViewModel(get{Name}UseCase: useCase)

        // When
        await sut.load(id: 1)

        // Then
        guard case .error = sut.state else {
            Issue.record("Expected error state")
            return
        }
    }

    @Test
    func loadCallsUseCaseWithCorrectId() async {
        // Given
        let useCase = Get{Name}UseCaseMock()
        useCase.result = .success(.stub())
        let sut = {Name}ViewModel(get{Name}UseCase: useCase)

        // When
        await sut.load(id: 42)

        // Then
        #expect(useCase.executeCallCount == 1)
        #expect(useCase.lastRequestedId == 42)
    }
}

private enum TestError: Error {
    case network
}
```

**Testing Rules:**
- `@MainActor` on test struct to access ViewModel
- Use `guard case` for enum state matching
- Use `Issue.record()` for test failures
- Test initial state, success, error, and call verification
- Router can be nil in tests (not testing navigation)

---

## Example: CharacterViewModel

### ViewState

```swift
// Sources/Presentation/ViewModels/CharacterViewState.swift
enum CharacterViewState {
    case idle
    case loading
    case loaded(Character)
    case error(Error)
}
```

### ViewModel

```swift
// Sources/Presentation/ViewModels/CharacterViewModel.swift
import SwiftUI

@MainActor
@Observable
final class CharacterViewModel {
    private(set) var state: CharacterViewState = .idle

    private let getCharacterUseCase: GetCharacterUseCaseContract
    private let router: CharacterRouter?

    init(
        getCharacterUseCase: GetCharacterUseCaseContract,
        router: CharacterRouter? = nil
    ) {
        self.getCharacterUseCase = getCharacterUseCase
        self.router = router
    }

    func load(id: Int) async {
        state = .loading
        do {
            let character = try await getCharacterUseCase.execute(id: id)
            state = .loaded(character)
        } catch {
            state = .error(error)
        }
    }
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| ViewState | internal | `Sources/Presentation/ViewModels/` |
| ViewModel | internal | `Sources/Presentation/ViewModels/` |

---

## Checklist

- [ ] Create ViewState enum with idle, loading, loaded, error cases
- [ ] Create ViewModel class with @MainActor and @Observable
- [ ] Inject UseCase via protocol (contract)
- [ ] Inject Router as optional dependency (see `/router` skill)
- [ ] Implement load/fetch method with state transitions
- [ ] Create tests for initial state, success, error, and call verification
- [ ] Run tests
