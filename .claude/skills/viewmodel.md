---
name: viewmodel
description: Creates ViewModels with state management. Use when creating ViewModels, implementing ViewState pattern, or adding state management for features.
---

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

## ViewModel Pattern (Detail - no navigation)

```swift
import SwiftUI

@Observable
final class {Name}DetailViewModel {
    private(set) var state: {Name}ViewState = .idle

    private let get{Name}UseCase: Get{Name}UseCaseContract

    init(get{Name}UseCase: Get{Name}UseCaseContract) {
        self.get{Name}UseCase = get{Name}UseCase
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

---

## ViewModel Pattern (List)

```swift
import SwiftUI

@Observable
final class {Name}ListViewModel {
    private(set) var state: {Name}ListViewState = .idle

    private let get{Name}sUseCase: Get{Name}sUseCaseContract

    init(get{Name}sUseCase: Get{Name}sUseCaseContract) {
        self.get{Name}sUseCase = get{Name}sUseCase
    }

    func load() async {
        state = .loading
        do {
            let items = try await get{Name}sUseCase.execute()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .error(error)
        }
    }
}
```

**Rules:**
- `@Observable` for SwiftUI integration (iOS 17+)
- `final class` to prevent subclassing
- **Internal visibility** (not public)
- Inject UseCases via **protocol (contract)**
- State is `private(set)` - only ViewModel mutates it
- Inject `RouterContract` for navigation (see `/router` skill)

---

## ViewModel Pattern (with Navigation)

ViewModels that trigger navigation receive `RouterContract`:

```swift
import ChallengeCore
import SwiftUI

@Observable
final class {Name}ListViewModel {
    private(set) var state: {Name}ListViewState = .idle

    private let get{Name}sUseCase: Get{Name}sUseCaseContract
    private let router: RouterContract

    init(get{Name}sUseCase: Get{Name}sUseCaseContract, router: RouterContract) {
        self.get{Name}sUseCase = get{Name}sUseCase
        self.router = router
    }

    func load() async {
        state = .loading
        do {
            let items = try await get{Name}sUseCase.execute()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .error(error)
        }
    }

    // Semantic navigation methods
    func didSelectItem(_ item: {Name}) {
        router.navigate(to: {Feature}Navigation.detail(identifier: item.id))
    }

    func didTapOnBack() {
        router.goBack()
    }
}
```

**Rules:**
- Inject `RouterContract` (not concrete Router)
- Use **semantic method names**: `didTapOn...`, `didSelect...`
- Never expose router to View
- See `/router` skill for full navigation documentation

---

## Testing

### ViewModel Tests

```swift
import Foundation
import Testing

@testable import Challenge{FeatureName}

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
        let sut = {Name}DetailViewModel(get{Name}UseCase: useCase)

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
- Use `guard case` for enum state matching
- Use `Issue.record()` for test failures
- Test initial state, success, error, and call verification

---

## Example: CharacterListViewModel

### ViewState

```swift
// Sources/Presentation/ViewModels/CharacterListViewState.swift
enum CharacterListViewState {
    case idle
    case loading
    case loaded([Character])
    case empty
    case error(Error)
}
```

### ViewModel

```swift
// Sources/Presentation/ViewModels/CharacterListViewModel.swift
import SwiftUI

@Observable
final class CharacterListViewModel {
    private(set) var state: CharacterListViewState = .idle

    private let getCharactersUseCase: GetCharactersUseCaseContract

    init(getCharactersUseCase: GetCharactersUseCaseContract) {
        self.getCharactersUseCase = getCharactersUseCase
    }

    func load() async {
        state = .loading
        do {
            let characters = try await getCharactersUseCase.execute()
            state = characters.isEmpty ? .empty : .loaded(characters)
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
- [ ] Create ViewModel class with @Observable
- [ ] Inject UseCase via protocol (contract)
- [ ] Implement load/fetch method with state transitions
- [ ] Create tests for initial state, success, error, and call verification
- [ ] Run tests
