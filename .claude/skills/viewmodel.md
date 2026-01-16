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

## ViewModel Pattern (List - with navigation)

List ViewModels receive Router and handle navigation:

```swift
import SwiftUI

@Observable
final class {Name}ListViewModel {
    private(set) var state: {Name}ListViewState = .idle

    private let get{Name}sUseCase: Get{Name}sUseCaseContract
    private let router: {Feature}Router

    init(
        get{Name}sUseCase: Get{Name}sUseCaseContract,
        router: {Feature}Router
    ) {
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

    func didSelect(_ item: {Name}) {
        router.navigate(to: .detail(item))
    }
}
```

**Rules:**
- `@Observable` for SwiftUI integration (iOS 17+)
- `final class` to prevent subclassing
- **Internal visibility** (not public)
- Inject UseCases via **protocol (contract)**
- **Router is required** for ViewModels that handle navigation
- State is `private(set)` - only ViewModel mutates it
- **`didSelect` methods** - Handle user actions and navigation

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

### List ViewModel Tests (with navigation)

```swift
struct {Name}ListViewModelTests {
    @Test
    func didSelectNavigatesToDetail() {
        // Given
        let router = {Feature}Router()
        let useCase = Get{Name}sUseCaseMock()
        let sut = {Name}ListViewModel(
            get{Name}sUseCase: useCase,
            router: router
        )
        let item = {Name}.stub()

        // When
        sut.didSelect(item)

        // Then
        #expect(router.path.count == 1)
    }
}
```

**Testing Rules:**
- Use `guard case` for enum state matching
- Use `Issue.record()` for test failures
- Test initial state, success, error, call verification, and **navigation**
- Use real Router in tests (verify path changes)

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

### ViewModel (with navigation)

```swift
// Sources/Presentation/ViewModels/CharacterListViewModel.swift
import SwiftUI

@Observable
final class CharacterListViewModel {
    private(set) var state: CharacterListViewState = .idle

    private let getCharactersUseCase: GetCharactersUseCaseContract
    private let router: CharacterRouter

    init(
        getCharactersUseCase: GetCharactersUseCaseContract,
        router: CharacterRouter
    ) {
        self.getCharactersUseCase = getCharactersUseCase
        self.router = router
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

    func didSelect(_ character: Character) {
        router.navigate(to: .detail(character))
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
- [ ] Inject Router if ViewModel handles navigation
- [ ] Implement load/fetch method with state transitions
- [ ] Implement `didSelect` methods for user actions (if navigating)
- [ ] Create tests for initial state, success, error, call verification, and navigation
- [ ] Run tests
