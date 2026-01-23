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
Features/{Feature}/
├── Sources/
│   └── Presentation/
│       └── {ScreenName}/                           # Group by screen (e.g., CharacterDetail)
│           ├── Navigation/
│           │   ├── {ScreenName}NavigatorContract.swift  # Navigator protocol
│           │   └── {ScreenName}Navigator.swift          # Navigator implementation
│           ├── Views/
│           │   └── {ScreenName}View.swift
│           └── ViewModels/
│               ├── {ScreenName}ViewState.swift     # ViewState enum
│               └── {ScreenName}ViewModel.swift     # ViewModel
└── Tests/
    └── Presentation/
        └── {ScreenName}/                           # Same structure as Sources
            ├── Navigation/
            │   └── {ScreenName}NavigatorTests.swift
            └── ViewModels/
                └── {ScreenName}ViewModelTests.swift
```

**Examples:**
- `Presentation/CharacterDetail/ViewModels/CharacterDetailViewModel.swift`
- `Presentation/CharacterDetail/Navigation/CharacterDetailNavigator.swift`
- `Presentation/CharacterList/ViewModels/CharacterListViewModel.swift`
- `Tests/Presentation/CharacterDetail/ViewModels/CharacterDetailViewModelTests.swift`

---

## ViewState Pattern

Use an enum to represent all possible states of a view:

```swift
enum {Name}ViewState {
    case idle
    case loading
    case loaded({Name})
    case error(Error)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            true
        case let (.loaded(lhsData), .loaded(rhsData)):
            lhsData == rhsData
        case let (.error(lhsError), .error(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }
}
```

**Rules:**
- **Internal visibility** (not public)
- One state enum per ViewModel
- `idle` is the initial state
- `loaded` contains the data
- `error` contains the Error
- Implement `==` operator for testability (enables direct comparison in tests)

### For lists:

```swift
enum {Name}ListViewState {
    case idle
    case loading
    case loaded([{Name}])
    case empty
    case error(Error)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.empty, .empty):
            true
        case let (.loaded(lhsData), .loaded(rhsData)):
            lhsData == rhsData
        case let (.error(lhsError), .error(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }
}
```

---

## ViewModel Pattern (Detail - no navigation)

```swift
import Foundation

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
import Foundation

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
- Inject `NavigatorContract` for navigation (see `/router` skill)

---

## ViewModel Pattern (with Navigation)

ViewModels that trigger navigation receive a **NavigatorContract**:

```swift
import Foundation

@Observable
final class {Name}ListViewModel {
    private(set) var state: {Name}ListViewState = .idle

    private let get{Name}sUseCase: Get{Name}sUseCaseContract
    private let navigator: {Name}ListNavigatorContract

    init(get{Name}sUseCase: Get{Name}sUseCaseContract, navigator: {Name}ListNavigatorContract) {
        self.get{Name}sUseCase = get{Name}sUseCase
        self.navigator = navigator
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
        navigator.navigateToDetail(id: item.id)
    }

    func didTapOnBack() {
        navigator.goBack()
    }
}
```

**Rules:**
- Inject **NavigatorContract** (not RouterContract directly)
- Use **semantic method names**: `didTapOn...`, `didSelect...`
- Never expose navigator to View
- Navigator handles internal vs external navigation details
- See `/router` skill for Navigator pattern documentation

---

## ViewModel Pattern (Stateless - navigation only)

ViewModels that **only trigger navigation** (no observable state) don't need `@Observable`:

```swift
/// Not @Observable: no state for the view to observe, only exposes actions.
final class {Name}ViewModel {
    private let navigator: {Name}NavigatorContract

    init(navigator: {Name}NavigatorContract) {
        self.navigator = navigator
    }

    func didTapOn{Action}() {
        navigator.navigateTo{Destination}()
    }
}
```

**When to use:**
- ViewModel has **no state** for the View to observe
- ViewModel only exposes **action methods** (navigation, triggers)
- View uses `let viewModel` instead of `@State private var viewModel`

**Example: HomeViewModel**

```swift
/// Not @Observable: no state for the view to observe, only exposes actions.
final class HomeViewModel {
    private let navigator: HomeNavigatorContract

    init(navigator: HomeNavigatorContract) {
        self.navigator = navigator
    }

    func didTapOnCharacterButton() {
        navigator.navigateToCharacters()
    }
}
```

**Corresponding View:**

```swift
struct HomeView: View {
    /// Not @State: ViewModel has no observable state, just actions.
    let viewModel: HomeViewModel

    var body: some View {
        Button("Go to Characters") {
            viewModel.didTapOnCharacterButton()
        }
    }
}
```

---

## Testing

### ViewModel Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}ViewModelTests {
    @Test
    func initialStateIsIdle() {
        // Given
        let useCaseMock = Get{Name}UseCaseMock()
        let navigatorMock = {Name}NavigatorMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock)

        // Then
        #expect(sut.state == .idle)
    }

    @Test
    func loadSetsLoadedStateOnSuccess() async {
        // Given
        let expected = {Name}.stub()
        let useCaseMock = Get{Name}UseCaseMock()
        useCaseMock.result = .success(expected)
        let navigatorMock = {Name}NavigatorMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load(id: 1)

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test
    func loadSetsErrorStateOnFailure() async {
        // Given
        let useCaseMock = Get{Name}UseCaseMock()
        useCaseMock.result = .failure(TestError.network)
        let navigatorMock = {Name}NavigatorMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load(id: 1)

        // Then
        #expect(sut.state == .error(TestError.network))
    }

    @Test
    func loadCallsUseCaseWithCorrectId() async {
        // Given
        let useCaseMock = Get{Name}UseCaseMock()
        useCaseMock.result = .success(.stub())
        let navigatorMock = {Name}NavigatorMock()
        let sut = {Name}DetailViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load(id: 42)

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedId == 42)
    }

    @Test
    func didSelectItemNavigatesToDetail() {
        // Given
        let useCaseMock = Get{Name}UseCaseMock()
        let navigatorMock = {Name}NavigatorMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock)

        // When
        sut.didSelectItem({Name}(id: 42))

        // Then
        #expect(navigatorMock.navigateToDetailIds == [42])
    }

    @Test
    func didTapOnBackCallsNavigator() {
        // Given
        let useCaseMock = Get{Name}UseCaseMock()
        let navigatorMock = {Name}NavigatorMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock)

        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}

private enum TestError: Error {
    case network
}
```

**Testing Rules:**
- Use **direct comparison** for state assertions when possible: `#expect(sut.state == .idle)`
- ViewState must implement `==` operator for direct comparison
- Test initial state, success, error, and call verification
- Use **NavigatorMock** to verify navigation calls (not RouterMock)

---

## Example: CharacterListViewModel

### ViewState

```swift
// Sources/Presentation/CharacterList/ViewModels/CharacterListViewState.swift
enum CharacterListViewState {
    case idle
    case loading
    case loaded(CharactersPage)  // Use custom type for pagination support
    case empty
    case error(Error)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.empty, .empty):
            true
        case let (.loaded(lhsPage), .loaded(rhsPage)):
            lhsPage == rhsPage
        case let (.error(lhsError), .error(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }
}
```

> **Note:** For lists with pagination, use a custom type like `CharactersPage` that includes pagination metadata (currentPage, totalPages, hasNextPage, etc.). For simple lists without pagination, use `[{Name}]` directly.

### ViewModel

```swift
// Sources/Presentation/CharacterList/ViewModels/CharacterListViewModel.swift
import Foundation

@Observable
final class CharacterListViewModel {
    private(set) var state: CharacterListViewState = .idle

    private let getCharactersUseCase: GetCharactersUseCaseContract
    private let navigator: CharacterListNavigatorContract

    init(getCharactersUseCase: GetCharactersUseCaseContract, navigator: CharacterListNavigatorContract) {
        self.getCharactersUseCase = getCharactersUseCase
        self.navigator = navigator
    }

    func load() async {
        state = .loading
        do {
            let result = try await getCharactersUseCase.execute(page: 1)
            state = result.characters.isEmpty ? .empty : .loaded(result)
        } catch {
            state = .error(error)
        }
    }

    func didSelect(_ character: Character) {
        navigator.navigateToDetail(id: character.id)
    }
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| ViewState | internal | `Sources/Presentation/{ScreenName}/ViewModels/` |
| ViewModel | internal | `Sources/Presentation/{ScreenName}/ViewModels/` |
| NavigatorContract | internal | `Sources/Presentation/{ScreenName}/Navigation/` |
| Navigator | internal | `Sources/Presentation/{ScreenName}/Navigation/` |

---

## Checklist

- [ ] Create ViewState enum with idle, loading, loaded, error cases
- [ ] Create ViewModel class with @Observable
- [ ] Inject UseCase via protocol (contract)
- [ ] Inject NavigatorContract for navigation (not RouterContract)
- [ ] Implement load/fetch method with state transitions
- [ ] Create tests for initial state, success, error, and call verification
- [ ] Create NavigatorMock for testing navigation
- [ ] Run tests
