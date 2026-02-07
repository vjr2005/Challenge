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
│           ├── Navigator/
│           │   ├── {ScreenName}NavigatorContract.swift  # Navigator protocol
│           │   └── {ScreenName}Navigator.swift          # Navigator implementation
│           ├── Tracker/
│           │   ├── {ScreenName}TrackerContract.swift    # Tracker protocol
│           │   ├── {ScreenName}Tracker.swift            # Tracker implementation
│           │   └── {ScreenName}Event.swift              # Tracking events
│           ├── Views/
│           │   └── {ScreenName}View.swift
│           └── ViewModels/
│               ├── {ScreenName}ViewState.swift     # ViewState enum
│               └── {ScreenName}ViewModel.swift     # ViewModel
└── Tests/
    └── Presentation/
        └── {ScreenName}/                           # Same structure as Sources
            ├── Navigator/
            │   └── {ScreenName}NavigatorTests.swift
            ├── Tracker/
            │   ├── {ScreenName}TrackerTests.swift
            │   └── {ScreenName}EventTests.swift
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

    func didAppear() async {
        await load()
    }

    func didTapOnRetryButton() async {
        await load()
    }
}

// MARK: - Private

private extension {Name}ListViewModel {
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
- `didAppear()` and `didTapOnRetryButton()` are public, `load()` is private (see "Protocol Method Naming Convention")

---

## ViewModel Pattern (with Navigation and Tracking)

ViewModels that trigger navigation receive a **NavigatorContract** and a **TrackerContract**:

```swift
import Foundation

@Observable
final class {Name}ListViewModel {
    private(set) var state: {Name}ListViewState = .idle

    private let get{Name}sUseCase: Get{Name}sUseCaseContract
    private let navigator: {Name}ListNavigatorContract
    private let tracker: {Name}ListTrackerContract

    init(
        get{Name}sUseCase: Get{Name}sUseCaseContract,
        navigator: {Name}ListNavigatorContract,
        tracker: {Name}ListTrackerContract
    ) {
        self.get{Name}sUseCase = get{Name}sUseCase
        self.navigator = navigator
        self.tracker = tracker
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
- Inject **TrackerContract** for screen-specific tracking
- Use **semantic method names**: `didTapOn...`, `didSelect...`
- Never expose navigator or tracker to View
- Navigator handles internal vs external navigation details
- Tracker handles event dispatching to the core tracker
- See `/navigator` skill for Navigator pattern documentation

---

## ViewModel Pattern (Stateless - navigation only)

ViewModels that **only trigger navigation** (no observable state) don't need `@Observable`:

```swift
/// Not @Observable: no state for the view to observe, only exposes actions.
final class {Name}ViewModel {
    private let navigator: {Name}NavigatorContract
    private let tracker: {Name}TrackerContract

    init(navigator: {Name}NavigatorContract, tracker: {Name}TrackerContract) {
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }

    func didTapOn{Action}() {
        tracker.track{Action}ButtonTapped()
        navigator.navigateTo{Destination}()
    }
}
```

**When to use:**
- ViewModel has **no state** for the View to observe
- ViewModel only exposes **action methods** (navigation, tracking, triggers)
- View uses `let viewModel` instead of `@State private var viewModel`

**Example: HomeViewModel**

```swift
/// Not @Observable: no state for the view to observe, only exposes actions.
final class HomeViewModel {
    private let navigator: HomeNavigatorContract
    private let tracker: HomeTrackerContract

    init(navigator: HomeNavigatorContract, tracker: HomeTrackerContract) {
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }

    func didTapOnCharacterButton() {
        tracker.trackCharacterButtonTapped()
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

## Protocol Method Naming Convention

All protocol methods describe the **UI event** that triggers them, using the `did` prefix:

| UI Event | Protocol Method |
|---|---|
| View appears (`.onFirstAppear {}`) | `didAppear()` |
| Tap on retry button | `didTapOnRetryButton()` |
| Pull to refresh (`.refreshable {}`) | `didPullToRefresh()` |
| Tap on "Load More" button | `didTapOnLoadMoreButton()` |
| Item selection | `didSelect(_:)` |
| Tap on button | `didTapOn{ButtonName}()` |

### Behavior Rules

- **`didAppear()`**: Called once via `.onFirstAppear` in the View. The `.onFirstAppear` modifier guarantees single execution, so the ViewModel does not need to guard against re-execution.
- **`didTapOnRetryButton()`**: Always calls `load()` unconditionally. The user has explicitly decided to retry.
- **`didPullToRefresh()`**: Always calls the refresh use case. Resets pagination to page 1.
- **`didTapOnLoadMoreButton()`**: Only loads if there is a next page and not already loading more.

---

## Preventing Unnecessary Reloads

The `.onFirstAppear` modifier (from `ChallengeCore`) executes only once when the view first appears, preventing unnecessary data reloads when returning from navigation. The ViewModel does not need to guard against re-execution because `.onFirstAppear` guarantees single invocation.

### Pattern: didAppear() + didTapOnRetryButton() + private load()

```swift
@Observable
final class {Name}ListViewModel {
    private(set) var state: {Name}ListViewState = .idle

    // Public: View calls this from .onFirstAppear - executes once
    func didAppear() async {
        await load()
    }

    // Public: View calls this from retry button - always reloads
    func didTapOnRetryButton() async {
        await load()
    }
}

private extension {Name}ListViewModel {
    // Private: Only called internally
    func load() async {
        state = .loading
        // fetch data...
    }
}
```

**Rules:**
- `didAppear()` is **public** - called by View in `.onFirstAppear`, guaranteed to execute once
- `didTapOnRetryButton()` is **public** - called by View in error retry button, always loads
- `load()` is **private** - encapsulates loading logic
- Single execution is guaranteed by `.onFirstAppear` in the View layer
- Error retry is the user's explicit choice via `didTapOnRetryButton()`

### View Integration

```swift
struct {Name}ListView: View {
    @State private var viewModel: {Name}ListViewModel

    var body: some View {
        content
            .onFirstAppear {
                await viewModel.didAppear()
            }
    }
}
```

### Debounced Search Pattern

ViewModels with search functionality use a debounced task to avoid excessive API calls:

```swift
@Observable
final class {Name}ListViewModel {
    var searchQuery: String = "" {
        didSet {
            if searchQuery != oldValue {
                searchQueryDidChange()
            }
        }
    }

    private let debounceInterval: Duration
    private(set) var searchTask: Task<Void, Never>?

    init(
        // ...other dependencies...
        debounceInterval: Duration = .milliseconds(300)
    ) {
        self.debounceInterval = debounceInterval
    }
}

private extension {Name}ListViewModel {
    func searchQueryDidChange() {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            try? await Task.sleep(for: debounceInterval)
            if !Task.isCancelled {
                await fetchResults()
            }
        }
    }
}
```

**Rules:**
- Inject `debounceInterval: Duration` with a default of `.milliseconds(300)`
- Expose `searchTask` as `private(set)` so tests can use `await sut.searchTask?.value` for deterministic waiting
- Cancel the previous task before creating a new one
- Check `Task.isCancelled` after the sleep to avoid stale executions

**Testing debounced search:**

```swift
// In test init: inject zero debounce
sut = {Name}ListViewModel(
    // ...other dependencies...
    debounceInterval: .zero
)

// In tests: wait for the debounce task deterministically
sut.searchQuery = "Rick"
await sut.searchTask?.value

#expect(searchUseCaseMock.lastRequestedQuery == "Rick")
```

> **Important:** Never use `Task.sleep` in tests to wait for debounce. Use `await sut.searchTask?.value` instead — it is deterministic and verified stable at 1000 iterations.

### Observable Properties with Guards

When using observable properties that trigger actions (like search), guard against unchanged values:

```swift
var searchQuery: String = "" {
    didSet {
        if searchQuery != oldValue {
            searchQueryDidChange()
        }
    }
}
```

**Why:** SwiftUI may re-set binding values during navigation transitions, triggering `didSet` even when the value hasn't changed. The guard prevents unnecessary reloads.

### Testing didAppear() and didTapOnRetryButton()

Test state transitions:

```swift
@Test("didTapOnRetryButton retries loading when in error state")
func didTapOnRetryButtonRetriesWhenError() async {
    // Given
    useCaseMock.result = .failure(.loadFailed)
    await sut.didAppear()

    // When
    useCaseMock.result = .success(.stub())
    await sut.didTapOnRetryButton()

    // Then
    #expect(useCaseMock.executeCallCount == 2)
}

@Test("didTapOnRetryButton always loads regardless of current state")
func didTapOnRetryButtonAlwaysLoads() async {
    // Given
    useCaseMock.result = .success(.stub())
    await sut.didAppear()

    // When
    await sut.didTapOnRetryButton()

    // Then
    #expect(useCaseMock.executeCallCount == 2)
}
```

---

## Pull-to-Refresh Pattern

Pull-to-refresh requires different strategies for lists vs details. Use **separate Get and Refresh UseCases** to follow the Single Responsibility Principle.

### List Refresh (Remote First)

For lists, use a dedicated `RefreshUseCase` that fetches from remote:

```swift
@Observable
final class {Name}ListViewModel {
    private let get{Name}sUseCase: Get{Name}sUseCaseContract        // localFirst
    private let refresh{Name}sUseCase: Refresh{Name}sUseCaseContract // remoteFirst

    func didPullToRefresh() async {
        currentPage = 1
        await refreshData()
    }
}

private extension {Name}ListViewModel {
    func refreshData() async {
        do {
            let result = try await refresh{Name}sUseCase.execute(page: currentPage)
            state = result.items.isEmpty ? .empty : .loaded(result)
        } catch {
            state = .error(error)
        }
    }
}
```

### Detail Refresh (Remote First)

For details, use separate Get (localFirst) and Refresh (remoteFirst) UseCases:

```swift
@Observable
final class {Name}DetailViewModel {
    private let identifier: Int
    private let get{Name}DetailUseCase: Get{Name}DetailUseCaseContract        // localFirst
    private let refresh{Name}DetailUseCase: Refresh{Name}DetailUseCaseContract // remoteFirst

    init(
        identifier: Int,
        get{Name}DetailUseCase: Get{Name}DetailUseCaseContract,
        refresh{Name}DetailUseCase: Refresh{Name}DetailUseCaseContract,
        navigator: {Name}DetailNavigatorContract,
        tracker: {Name}DetailTrackerContract
    ) { ... }

    func didPullToRefresh() async {
        do {
            let item = try await refresh{Name}DetailUseCase.execute(identifier: identifier)
            state = .loaded(item)
        } catch {
            state = .error(error)
        }
    }
}
```

> **IMPORTANT:**
> - **Get UseCases** use `localFirst` cache policy (fast initial load)
> - **Refresh UseCases** use `remoteFirst` cache policy (pull-to-refresh)
> - ViewModels don't know about cache policies - they just call the appropriate UseCase
> - See `/usecase` skill for naming conventions and implementation details

### View Integration

```swift
ScrollView {
    // content...
}
.refreshable {
    await viewModel.didPullToRefresh()
}
```

### Testing List Refresh

```swift
@Test("didPullToRefresh calls refresh use case")
func didPullToRefreshCallsRefreshUseCase() async {
    // Given
    refreshUseCaseMock.result = .success(.stub())

    // When
    await sut.didPullToRefresh()

    // Then
    #expect(refreshUseCaseMock.executeCallCount == 1)
}
```

### Testing Detail Refresh

```swift
@Test("didPullToRefresh updates from API using refresh use case")
func didPullToRefreshUpdatesFromAPI() async {
    // Given
    getUseCaseMock.result = .success(.stub())
    await sut.didAppear()
    refreshUseCaseMock.result = .success(.stub(name: "Refreshed"))

    // When
    await sut.didPullToRefresh()

    // Then
    #expect(refreshUseCaseMock.executeCallCount == 1)
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
        let trackerMock = {Name}TrackerMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock, tracker: trackerMock)

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
        let trackerMock = {Name}TrackerMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock, tracker: trackerMock)

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
        let trackerMock = {Name}TrackerMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock, tracker: trackerMock)

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
        let trackerMock = {Name}TrackerMock()
        let sut = {Name}DetailViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock, tracker: trackerMock)

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
        let trackerMock = {Name}TrackerMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock, tracker: trackerMock)

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
        let trackerMock = {Name}TrackerMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock, tracker: trackerMock)

        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }

    @Test
    func didAppearTracksScreenViewed() async {
        // Given
        let useCaseMock = Get{Name}UseCaseMock()
        useCaseMock.result = .success(.stub())
        let navigatorMock = {Name}NavigatorMock()
        let trackerMock = {Name}TrackerMock()
        let sut = {Name}ViewModel(get{Name}UseCase: useCaseMock, navigator: navigatorMock, tracker: trackerMock)

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
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
- Use **TrackerMock** to verify tracking calls

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

    private let getCharactersPageUseCase: GetCharactersPageUseCaseContract
    private let navigator: CharacterListNavigatorContract
    private let tracker: CharacterListTrackerContract

    init(
        getCharactersPageUseCase: GetCharactersPageUseCaseContract,
        navigator: CharacterListNavigatorContract,
        tracker: CharacterListTrackerContract
    ) {
        self.getCharactersPageUseCase = getCharactersPageUseCase
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() async {
        tracker.trackScreenViewed()
        await load()
    }

    func didTapOnRetryButton() async {
        tracker.trackRetryButtonTapped()
        await load()
    }

    func didSelect(_ character: Character) {
        tracker.trackCharacterSelected(identifier: character.id)
        navigator.navigateToDetail(id: character.id)
    }
}

// MARK: - Private

private extension CharacterListViewModel {
    func load() async {
        state = .loading
        do {
            let result = try await getCharactersPageUseCase.execute(page: 1)
            state = result.characters.isEmpty ? .empty : .loaded(result)
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
| ViewState | internal | `Sources/Presentation/{ScreenName}/ViewModels/` |
| ViewModel | internal | `Sources/Presentation/{ScreenName}/ViewModels/` |
| NavigatorContract | internal | `Sources/Presentation/{ScreenName}/Navigator/` |
| Navigator | internal | `Sources/Presentation/{ScreenName}/Navigator/` |
| TrackerContract | internal | `Sources/Presentation/{ScreenName}/Tracker/` |
| Tracker | internal | `Sources/Presentation/{ScreenName}/Tracker/` |
| Event | internal | `Sources/Presentation/{ScreenName}/Tracker/` |

---

## Checklist

- [ ] Create ViewState enum with idle, loading, loaded, error cases
- [ ] Create ViewModel class with @Observable
- [ ] Inject UseCase via protocol (contract)
- [ ] Inject NavigatorContract for navigation (not RouterContract)
- [ ] Inject TrackerContract for screen-specific tracking
- [ ] Implement `didAppear()` and `didTapOnRetryButton()` as public, `load()` as private
- [ ] Add tracking calls in `didAppear()`, `didSelect()`, `didTapOn...()` methods
- [ ] Guard observable properties with `oldValue` check in `didSet`
- [ ] Create tests for initial state, success, error, and call verification
- [ ] Create tests for `didAppear()` and `didTapOnRetryButton()` behavior
- [ ] Create NavigatorMock for testing navigation
- [ ] Create TrackerMock for testing tracking calls
- [ ] Run tests
