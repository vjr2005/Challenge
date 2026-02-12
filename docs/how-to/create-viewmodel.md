# How To: Create ViewModel

Create ViewModels for state management with the ViewState pattern.

## Scope & Boundaries

This guide owns **only** `Sources/Presentation/{Screen}/ViewModels/` and its tests.

| Need | Delegate to |
|------|-------------|
| Domain UseCases | [Create UseCase](create-usecase.md) |
| Container / Feature wiring | [Create Feature](create-feature.md) |
| Navigator / Tracker | [Create Navigator](create-navigator.md) |

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- UseCase exists (see [Create UseCase](create-usecase.md))
- Navigator exists (see [Create Navigator](create-navigator.md))
- Tracker exists (see [Create Tracker](create-tracker.md))

## File Structure

```
Features/{Feature}/
├── Sources/Presentation/{Screen}/
│   └── ViewModels/
│       ├── {Screen}ViewModelContract.swift
│       ├── {Screen}ViewState.swift          # Only for stateful ViewModels
│       └── {Screen}ViewModel.swift
└── Tests/
    ├── Unit/Presentation/{Screen}/
    │   └── ViewModels/
    │       └── {Screen}ViewModelTests.swift
    └── Shared/Mocks/
        └── {Screen}ViewModelMock.swift
```

---

## Workflow

### Step 1 — Identify ViewModel Type

| Type | When | Go to |
|------|------|-------|
| Stateless | Navigation + tracking only, no observable state | [Step 3a](#step-3a--stateless) |
| Stateful Detail | Single item load + optional refresh | [Step 3b](#step-3b--stateful-detail) |
| Stateful List | List load + empty/error + optional refresh | [Step 3c](#step-3c--stateful-list) |
| Debounced Search | Search with debounce + recent searches (extends list) | [Step 3d](#step-3d--debounced-search) |
| Stateful Filter | Mutable filter with computed properties | [Step 3e](#step-3e--stateful-filter) |

### Step 2 — Ensure UseCases Exist

Before creating the ViewModel, verify required UseCases exist in `Sources/Domain/UseCases/`.

- **UseCases found?** → Go to Step 3
- **No UseCases found?** → See [Create UseCase](create-usecase.md) first. Return here after completion.

### Step 3 — Implement ViewModel

---

## Core Conventions

### Class Rules

- `@Observable` **only** when `private(set) var` state exists; stateless ViewModels are plain `final class`
- `final class`, internal visibility, no explicit `@MainActor` (project default isolation)
- Protocol = `{Screen}ViewModelContract: AnyObject`

### Method Naming

All protocol methods describe the **UI event**, using the `did` prefix:

| UI Event | Protocol Method |
|----------|-----------------|
| View appears (`.onFirstAppear {}`) | `didAppear()` |
| Tap retry button | `didTapOnRetryButton()` |
| Pull to refresh (`.refreshable {}`) | `didPullToRefresh()` |
| Tap load more button | `didTapOnLoadMoreButton()` |
| Item selection | `didSelect(_:)` |
| Tap on button | `didTapOn{ButtonName}()` |

### Behavior Rules

- **`didAppear()`**: Called once via `.onFirstAppear` — single execution guaranteed by the View
- **`didTapOnRetryButton()`**: Always calls `load()` unconditionally
- **`didPullToRefresh()`**: Always calls the refresh use case, resets pagination
- **`didTapOnLoadMoreButton()`**: Only loads if there is a next page and not already loading more
- Public methods (`didAppear`, `didTapOnRetryButton`) call private `load()` — encapsulate loading logic

### ViewState `==` Operator

All ViewState enums implement `==` **on the enum itself** for testability (enables direct state comparison in tests). Error cases compare via `localizedDescription`.

---

## Step 3a — Stateless

Navigation and tracking only — no observable state. View uses `let viewModel` instead of `@State private var viewModel`.

### 1. Create ViewModel Contract

Create `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewModelContract.swift`:

```swift
protocol {Screen}ViewModelContract {
    func didAppear()
    func didTapOn{Action}()
}
```

No `AnyObject` needed unless View uses `@State`. No `async` — stateless ViewModels are synchronous.

### 2. Create ViewModel

Create `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewModel.swift`:

```swift
/// Not @Observable: no state for the view to observe, only exposes actions.
final class {Screen}ViewModel: {Screen}ViewModelContract {
    private let navigator: {Screen}NavigatorContract
    private let tracker: {Screen}TrackerContract

    init(navigator: {Screen}NavigatorContract, tracker: {Screen}TrackerContract) {
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

### 3. Create Mock

Create `Tests/Shared/Mocks/{Screen}ViewModelMock.swift`:

```swift
@testable import {AppName}{Feature}

final class {Screen}ViewModelMock: {Screen}ViewModelContract, @unchecked Sendable {
    private(set) var didAppearCallCount = 0
    private(set) var didTapOn{Action}CallCount = 0

    @MainActor init() {}

    func didAppear() {
        didAppearCallCount += 1
    }

    func didTapOn{Action}() {
        didTapOn{Action}CallCount += 1
    }
}
```

### 4. Create Tests

Create `Tests/Unit/Presentation/{Screen}/ViewModels/{Screen}ViewModelTests.swift`:

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewModelTests {
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    init() {
        sut = {Screen}ViewModel(navigator: navigatorMock, tracker: trackerMock)
    }

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    @Test("didTapOn{Action} navigates to {Destination}")
    func didTapOnActionNavigatesToDestination() {
        // When
        sut.didTapOn{Action}()

        // Then
        #expect(navigatorMock.navigateTo{Destination}CallCount == 1)
    }

    @Test("didTapOn{Action} tracks button tapped")
    func didTapOnActionTracksButtonTapped() {
        // When
        sut.didTapOn{Action}()

        // Then
        #expect(trackerMock.{action}ButtonTappedCallCount == 1)
    }
}
```

---

## Step 3b — Stateful Detail

Single item load with optional pull-to-refresh. Uses `@Observable` with `private(set) var state`.

### 1. Create ViewState

Create `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewState.swift`:

```swift
import Foundation

enum {Screen}ViewState {
    case idle
    case loading
    case loaded({Name})
    case error({Feature}Error)

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

### 2. Create ViewModel Contract

Create `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewModelContract.swift`:

```swift
import Foundation

protocol {Screen}ViewModelContract: AnyObject {
    var state: {Screen}ViewState { get }
    func didAppear() async
    func didTapOnRetryButton() async
    func didPullToRefresh() async    // Only if refresh is needed
    func didTapOnBack()              // Only if navigation back is needed
}
```

### 3. Create ViewModel

Create `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewModel.swift`:

```swift
import Foundation

@Observable
final class {Screen}ViewModel: {Screen}ViewModelContract {
    private(set) var state: {Screen}ViewState = .idle

    private let identifier: Int
    private let get{Name}UseCase: Get{Name}UseCaseContract
    private let refresh{Name}UseCase: Refresh{Name}UseCaseContract    // Only if refresh
    private let navigator: {Screen}NavigatorContract
    private let tracker: {Screen}TrackerContract

    init(
        identifier: Int,
        get{Name}UseCase: Get{Name}UseCaseContract,
        refresh{Name}UseCase: Refresh{Name}UseCaseContract,
        navigator: {Screen}NavigatorContract,
        tracker: {Screen}TrackerContract
    ) {
        self.identifier = identifier
        self.get{Name}UseCase = get{Name}UseCase
        self.refresh{Name}UseCase = refresh{Name}UseCase
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() async {
        tracker.trackScreenViewed(identifier: identifier)
        await load()
    }

    func didTapOnRetryButton() async {
        tracker.trackRetryButtonTapped()
        await load()
    }

    func didPullToRefresh() async {
        tracker.trackPullToRefreshTriggered()
        await refresh()
    }

    func didTapOnBack() {
        tracker.trackBackButtonTapped()
        navigator.goBack()
    }
}

// MARK: - Private

private extension {Screen}ViewModel {
    func load() async {
        state = .loading
        do {
            let item = try await get{Name}UseCase.execute(identifier: identifier)
            state = .loaded(item)
        } catch {
            tracker.trackLoadError(description: error.debugDescription)
            state = .error(error)
        }
    }

    func refresh() async {
        do {
            let item = try await refresh{Name}UseCase.execute(identifier: identifier)
            state = .loaded(item)
        } catch {
            tracker.trackRefreshError(description: error.debugDescription)
            state = .error(error)
        }
    }
}
```

**Key patterns:**
- `@Observable` for SwiftUI integration (iOS 17+)
- `didAppear()` and `didTapOnRetryButton()` are public, `load()` is private
- **Separate Get and Refresh UseCases** — each with a single responsibility
- `load()` uses Get UseCase (localFirst cache policy)
- `refresh()` does NOT set `state = .loading` — the current content stays visible during pull-to-refresh
- All tracker calls in public methods + error tracking in private methods
- State is `private(set)` — only ViewModel mutates it

### 4. Create Mock

Create `Tests/Shared/Mocks/{Screen}ViewModelMock.swift`:

```swift
@testable import {AppName}{Feature}

final class {Screen}ViewModelMock: {Screen}ViewModelContract, @unchecked Sendable {
    var state: {Screen}ViewState = .idle
    private(set) var didAppearCallCount = 0
    private(set) var didTapOnRetryButtonCallCount = 0
    private(set) var didPullToRefreshCallCount = 0
    private(set) var didTapOnBackCallCount = 0

    @MainActor init() {}

    func didAppear() async {
        didAppearCallCount += 1
    }

    func didTapOnRetryButton() async {
        didTapOnRetryButtonCallCount += 1
    }

    func didPullToRefresh() async {
        didPullToRefreshCallCount += 1
    }

    func didTapOnBack() {
        didTapOnBackCallCount += 1
    }
}
```

### 5. Create Tests

Create `Tests/Unit/Presentation/{Screen}/ViewModels/{Screen}ViewModelTests.swift`:

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewModelTests {
    private let getUseCaseMock = Get{Name}UseCaseMock()
    private let refreshUseCaseMock = Refresh{Name}UseCaseMock()
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    init() {
        sut = {Screen}ViewModel(
            identifier: 1,
            get{Name}UseCase: getUseCaseMock,
            refresh{Name}UseCase: refreshUseCaseMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    @Test("Initial state is idle")
    func initialStateIsIdle() {
        #expect(sut.state == .idle)
    }

    @Test("didAppear sets loaded state on success")
    func didAppearSetsLoadedOnSuccess() async {
        // Given
        let expected = {Name}.stub()
        getUseCaseMock.result = .success(expected)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("didAppear sets error state on failure")
    func didAppearSetsErrorOnFailure() async {
        // Given
        getUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .error(.loadFailed()))
    }

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() async {
        // Given
        getUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    @Test("didTapOnRetryButton retries loading")
    func didTapOnRetryButtonRetriesLoading() async {
        // Given
        getUseCaseMock.result = .failure(.loadFailed())
        await sut.didAppear()

        // When
        getUseCaseMock.result = .success(.stub())
        await sut.didTapOnRetryButton()

        // Then
        #expect(getUseCaseMock.executeCallCount == 2)
    }

    @Test("didPullToRefresh calls refresh use case")
    func didPullToRefreshCallsRefreshUseCase() async {
        // Given
        refreshUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshUseCaseMock.executeCallCount == 1)
    }

    @Test("didPullToRefresh updates state on success")
    func didPullToRefreshUpdatesState() async {
        // Given
        getUseCaseMock.result = .success(.stub())
        await sut.didAppear()
        let refreshed = {Name}.stub(name: "Refreshed")
        refreshUseCaseMock.result = .success(refreshed)

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(sut.state == .loaded(refreshed))
    }

    @Test("didTapOnBack navigates back")
    func didTapOnBackNavigatesBack() {
        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}
```

---

## Step 3c — Stateful List

List load with empty/error states and optional pull-to-refresh. Uses `@Observable` with `private(set) var state`.

### 1. Create ViewState

Create `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewState.swift`:

```swift
import Foundation

enum {Screen}ViewState {
    case idle
    case loading
    case loaded([{Name}])
    case empty
    case error({Feature}Error)

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

> **Note:** For lists with pagination, replace `[{Name}]` with a custom type like `{Name}sPage` that includes pagination metadata (currentPage, totalPages, hasNextPage, etc.).

### 2. Create ViewModel Contract

Create `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewModelContract.swift`:

```swift
import Foundation

protocol {Screen}ViewModelContract: AnyObject {
    var state: {Screen}ViewState { get }
    func didAppear() async
    func didTapOnRetryButton() async
    func didPullToRefresh() async    // Only if refresh is needed
    func didSelect(_ item: {Name})   // Only if navigation is needed
}
```

### 3. Create ViewModel

Create `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewModel.swift`:

```swift
import Foundation

@Observable
final class {Screen}ViewModel: {Screen}ViewModelContract {
    private(set) var state: {Screen}ViewState = .idle

    private let get{Name}sUseCase: Get{Name}sUseCaseContract
    private let refresh{Name}sUseCase: Refresh{Name}sUseCaseContract    // Only if refresh
    private let navigator: {Screen}NavigatorContract
    private let tracker: {Screen}TrackerContract

    init(
        get{Name}sUseCase: Get{Name}sUseCaseContract,
        refresh{Name}sUseCase: Refresh{Name}sUseCaseContract,
        navigator: {Screen}NavigatorContract,
        tracker: {Screen}TrackerContract
    ) {
        self.get{Name}sUseCase = get{Name}sUseCase
        self.refresh{Name}sUseCase = refresh{Name}sUseCase
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

    func didPullToRefresh() async {
        tracker.trackPullToRefreshTriggered()
        await refreshData()
    }

    func didSelect(_ item: {Name}) {
        tracker.track{Name}Selected(identifier: item.id)
        navigator.navigateToDetail(identifier: item.id)
    }
}

// MARK: - Private

private extension {Screen}ViewModel {
    func load() async {
        state = .loading
        do {
            let items = try await get{Name}sUseCase.execute()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            tracker.trackFetchError(description: error.debugDescription)
            state = .error(error)
        }
    }

    func refreshData() async {
        do {
            let items = try await refresh{Name}sUseCase.execute()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            tracker.trackRefreshError(description: error.debugDescription)
            state = .error(error)
        }
    }
}
```

> **Note:** `refreshData()` does NOT set `state = .loading` — the current content stays visible during pull-to-refresh.

### 4. Create Mock

Create `Tests/Shared/Mocks/{Screen}ViewModelMock.swift`:

```swift
@testable import {AppName}{Feature}

final class {Screen}ViewModelMock: {Screen}ViewModelContract, @unchecked Sendable {
    var state: {Screen}ViewState = .idle
    private(set) var didAppearCallCount = 0
    private(set) var didTapOnRetryButtonCallCount = 0
    private(set) var didPullToRefreshCallCount = 0
    private(set) var lastSelectedItem: {Name}?

    @MainActor init() {}

    func didAppear() async {
        didAppearCallCount += 1
    }

    func didTapOnRetryButton() async {
        didTapOnRetryButtonCallCount += 1
    }

    func didPullToRefresh() async {
        didPullToRefreshCallCount += 1
    }

    func didSelect(_ item: {Name}) {
        lastSelectedItem = item
    }
}
```

### 5. Create Tests

Create `Tests/Unit/Presentation/{Screen}/ViewModels/{Screen}ViewModelTests.swift`:

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewModelTests {
    private let getUseCaseMock = Get{Name}sUseCaseMock()
    private let refreshUseCaseMock = Refresh{Name}sUseCaseMock()
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    init() {
        sut = {Screen}ViewModel(
            get{Name}sUseCase: getUseCaseMock,
            refresh{Name}sUseCase: refreshUseCaseMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    @Test("Initial state is idle")
    func initialStateIsIdle() {
        #expect(sut.state == .idle)
    }

    @Test("didAppear sets loaded state on success")
    func didAppearSetsLoadedOnSuccess() async {
        // Given
        let expected: [{Name}] = [.stub()]
        getUseCaseMock.result = .success(expected)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("didAppear sets empty state when no items")
    func didAppearSetsEmptyWhenNoItems() async {
        // Given
        getUseCaseMock.result = .success([])

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .empty)
    }

    @Test("didAppear sets error state on failure")
    func didAppearSetsErrorOnFailure() async {
        // Given
        getUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .error(.loadFailed()))
    }

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() async {
        // Given
        getUseCaseMock.result = .success([.stub()])

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    @Test("didTapOnRetryButton retries loading")
    func didTapOnRetryButtonRetriesLoading() async {
        // Given
        getUseCaseMock.result = .failure(.loadFailed())
        await sut.didAppear()

        // When
        getUseCaseMock.result = .success([.stub()])
        await sut.didTapOnRetryButton()

        // Then
        #expect(getUseCaseMock.executeCallCount == 2)
    }

    @Test("didPullToRefresh calls refresh use case")
    func didPullToRefreshCallsRefreshUseCase() async {
        // Given
        refreshUseCaseMock.result = .success([.stub()])

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshUseCaseMock.executeCallCount == 1)
    }

    @Test("didSelect navigates to detail")
    func didSelectNavigatesToDetail() {
        // Given
        let item = {Name}.stub()

        // When
        sut.didSelect(item)

        // Then
        #expect(navigatorMock.navigateToDetailIdentifiers == [item.id])
    }

    @Test("didSelect tracks item selected")
    func didSelectTracksItemSelected() {
        // Given
        let item = {Name}.stub()

        // When
        sut.didSelect(item)

        // Then
        #expect(trackerMock.{name}SelectedCallCount == 1)
    }
}
```

---

## Step 3d — Debounced Search

Extends the stateful list pattern with search query debouncing and recent searches.

### Contract

```swift
import Foundation

protocol {Screen}ViewModelContract: AnyObject {
    var state: {Screen}ViewState { get }
    var searchQuery: String { get set }
    var recentSearches: [String] { get }
    func didAppear() async
    func didTapOnRetryButton() async
    func didPullToRefresh() async
    func didSelect(_ item: {Name})
    func didSelectRecentSearch(_ query: String) async
    func didDeleteRecentSearch(_ query: String) async
}
```

### Search Property with Guard

```swift
var searchQuery: String = "" {
    didSet {
        if searchQuery != oldValue {
            searchQueryDidChange()
        }
    }
}
```

> **Why:** SwiftUI may re-set binding values during navigation transitions, triggering `didSet` even when the value hasn't changed. The guard prevents unnecessary reloads.

### Debounce Mechanism

```swift
@Observable
final class {Screen}ViewModel: {Screen}ViewModelContract {
    private(set) var state: {Screen}ViewState = .idle
    private(set) var recentSearches: [String] = []
    var searchQuery: String = "" {
        didSet {
            if searchQuery != oldValue {
                searchQueryDidChange()
            }
        }
    }

    private let get{Name}sUseCase: Get{Name}sUseCaseContract
    private let search{Name}sUseCase: Search{Name}sUseCaseContract
    private let getRecentSearchesUseCase: GetRecentSearchesUseCaseContract
    private let saveRecentSearchUseCase: SaveRecentSearchUseCaseContract
    private let deleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract
    private let navigator: {Screen}NavigatorContract
    private let tracker: {Screen}TrackerContract
    private let debounceInterval: Duration
    private(set) var searchTask: Task<Void, Never>?

    init(
        get{Name}sUseCase: Get{Name}sUseCaseContract,
        search{Name}sUseCase: Search{Name}sUseCaseContract,
        getRecentSearchesUseCase: GetRecentSearchesUseCaseContract,
        saveRecentSearchUseCase: SaveRecentSearchUseCaseContract,
        deleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract,
        navigator: {Screen}NavigatorContract,
        tracker: {Screen}TrackerContract,
        debounceInterval: Duration = .milliseconds(300)
    ) {
        self.get{Name}sUseCase = get{Name}sUseCase
        self.search{Name}sUseCase = search{Name}sUseCase
        self.getRecentSearchesUseCase = getRecentSearchesUseCase
        self.saveRecentSearchUseCase = saveRecentSearchUseCase
        self.deleteRecentSearchUseCase = deleteRecentSearchUseCase
        self.navigator = navigator
        self.tracker = tracker
        self.debounceInterval = debounceInterval
    }

    // ... public methods (didAppear, didTapOnRetryButton, etc.)

    func didSelectRecentSearch(_ query: String) async {
        searchQuery = query
        searchTask?.cancel()
        await saveRecentSearchUseCase.execute(query: query)
        await loadRecentSearches()
        tracker.trackSearchPerformed(query: query)
        await fetchResults()
    }

    func didDeleteRecentSearch(_ query: String) async {
        await deleteRecentSearchUseCase.execute(query: query)
        await loadRecentSearches()
    }
}

// MARK: - Private

private extension {Screen}ViewModel {
    var normalizedQuery: String? {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    func searchQueryDidChange() {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            try? await Task.sleep(for: debounceInterval)
            if !Task.isCancelled {
                if let query = normalizedQuery {
                    tracker.trackSearchPerformed(query: query)
                    await saveRecentSearchUseCase.execute(query: query)
                    await loadRecentSearches()
                }
                await fetchResults()
            }
        }
    }

    func fetchResults() async {
        do {
            let result: [{Name}]
            if let query = normalizedQuery {
                result = try await search{Name}sUseCase.execute(query: query)
            } else {
                result = try await get{Name}sUseCase.execute()
            }
            state = result.isEmpty ? .empty : .loaded(result)
        } catch {
            guard !Task.isCancelled else { return }
            tracker.trackFetchError(description: error.debugDescription)
            state = .error(error)
        }
    }

    func loadRecentSearches() async {
        recentSearches = await getRecentSearchesUseCase.execute()
    }
}
```

**Debounce Rules:**
- Inject `debounceInterval: Duration` with default `.milliseconds(300)`
- Expose `searchTask` as `private(set)` for deterministic test waiting
- Cancel the previous task before creating a new one
- Check `Task.isCancelled` after the sleep to avoid stale executions
- Guard against `Task.isCancelled` in the catch block to ignore errors from cancelled requests

### Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewModelTests {
    private let getUseCaseMock = Get{Name}sUseCaseMock()
    private let searchUseCaseMock = Search{Name}sUseCaseMock()
    private let getRecentSearchesMock = GetRecentSearchesUseCaseMock()
    private let saveRecentSearchMock = SaveRecentSearchUseCaseMock()
    private let deleteRecentSearchMock = DeleteRecentSearchUseCaseMock()
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    init() {
        sut = {Screen}ViewModel(
            get{Name}sUseCase: getUseCaseMock,
            search{Name}sUseCase: searchUseCaseMock,
            getRecentSearchesUseCase: getRecentSearchesMock,
            saveRecentSearchUseCase: saveRecentSearchMock,
            deleteRecentSearchUseCase: deleteRecentSearchMock,
            navigator: navigatorMock,
            tracker: trackerMock,
            debounceInterval: .zero    // Zero debounce for tests
        )
    }

    @Test("Search query triggers debounced search")
    func searchQueryTriggersSearch() async {
        // Given
        searchUseCaseMock.result = .success([.stub()])

        // When
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then
        #expect(searchUseCaseMock.lastRequestedQuery == "Rick")
    }

    @Test("Search query guards against unchanged value")
    func searchQueryGuardsUnchanged() async {
        // Given
        searchUseCaseMock.result = .success([.stub()])
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // When — set same value again
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then — only one search call
        #expect(searchUseCaseMock.executeCallCount == 1)
    }

    @Test("Empty search query fetches all items")
    func emptySearchFetchesAll() async {
        // Given
        getUseCaseMock.result = .success([.stub()])
        searchUseCaseMock.result = .success([.stub()])
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // When
        sut.searchQuery = ""
        await sut.searchTask?.value

        // Then
        #expect(getUseCaseMock.executeCallCount == 1)
    }

    @Test("didSelectRecentSearch searches immediately")
    func didSelectRecentSearchSearchesImmediately() async {
        // Given
        searchUseCaseMock.result = .success([.stub()])

        // When
        await sut.didSelectRecentSearch("Rick")

        // Then
        #expect(searchUseCaseMock.lastRequestedQuery == "Rick")
    }

    @Test("didDeleteRecentSearch removes and reloads")
    func didDeleteRecentSearchRemovesAndReloads() async {
        // When
        await sut.didDeleteRecentSearch("Rick")

        // Then
        #expect(deleteRecentSearchMock.executeCallCount == 1)
        #expect(getRecentSearchesMock.executeCallCount == 1)
    }
}
```

> **Important:** Never use `Task.sleep` in tests to wait for debounce. Use `await sut.searchTask?.value` instead — it is deterministic and verified stable at 1000 iterations.

---

## Step 3e — Stateful Filter

Mutable filter with computed properties and delegate pattern. Uses `@Observable` with a mutable `var filter`.

### Delegate Protocol

```swift
protocol {Name}FilterDelegate: AnyObject, Sendable {
    var currentFilter: {Name}Filter { get }
    func didApplyFilter(_ filter: {Name}Filter)
}
```

### Contract

```swift
protocol {Screen}ViewModelContract: AnyObject {
    var filter: {Name}Filter { get set }
    var hasActiveFilters: Bool { get }
    func didAppear()
    func didTapApply()
    func didTapReset()
    func didTapClose()
}
```

No `async` methods — filter ViewModels are synchronous.

### ViewModel

```swift
import Foundation

@Observable
final class {Screen}ViewModel: {Screen}ViewModelContract {
    var filter: {Name}Filter

    var hasActiveFilters: Bool {
        filter.activeFilterCount > 0
    }

    private let delegate: any {Name}FilterDelegate
    private let navigator: {Screen}NavigatorContract
    private let tracker: {Screen}TrackerContract

    init(
        delegate: any {Name}FilterDelegate,
        navigator: {Screen}NavigatorContract,
        tracker: {Screen}TrackerContract
    ) {
        self.filter = delegate.currentFilter
        self.delegate = delegate
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }

    func didTapApply() {
        tracker.trackApplyFilters(filterCount: filter.activeFilterCount)
        delegate.didApplyFilter(filter)
        navigator.dismiss()
    }

    func didTapReset() {
        filter = .empty
        tracker.trackResetFilters()
    }

    func didTapClose() {
        tracker.trackCloseTapped()
        navigator.dismiss()
    }
}
```

> **Note:** The delegate is typed as `any {Name}FilterDelegate` because it comes from a different module (the parent ViewModel).

### Mock

```swift
@testable import {AppName}{Feature}

final class {Screen}ViewModelMock: {Screen}ViewModelContract, @unchecked Sendable {
    var filter: {Name}Filter = .empty
    var hasActiveFilters: Bool { filter.activeFilterCount > 0 }
    private(set) var didAppearCallCount = 0
    private(set) var didTapApplyCallCount = 0
    private(set) var didTapResetCallCount = 0
    private(set) var didTapCloseCallCount = 0

    @MainActor init() {}

    func didAppear() { didAppearCallCount += 1 }
    func didTapApply() { didTapApplyCallCount += 1 }
    func didTapReset() { didTapResetCallCount += 1 }
    func didTapClose() { didTapCloseCallCount += 1 }
}
```

### Delegate Mock (for testing)

```swift
@testable import {AppName}{Feature}

final class {Name}FilterDelegateMock: {Name}FilterDelegate, @unchecked Sendable {
    var currentFilter: {Name}Filter = .empty
    private(set) var didApplyFilterCallCount = 0
    private(set) var lastAppliedFilter: {Name}Filter?

    @MainActor init() {}

    func didApplyFilter(_ filter: {Name}Filter) {
        didApplyFilterCallCount += 1
        lastAppliedFilter = filter
    }
}
```

### Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewModelTests {
    private let delegateMock = {Name}FilterDelegateMock()
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    init() {
        sut = {Screen}ViewModel(
            delegate: delegateMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    @Test("Initial filter matches delegate current filter")
    func initialFilterMatchesDelegate() {
        #expect(sut.filter == delegateMock.currentFilter)
    }

    @Test("hasActiveFilters is false with empty filter")
    func hasActiveFiltersIsFalseWhenEmpty() {
        #expect(sut.hasActiveFilters == false)
    }

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    @Test("didTapApply delegates filter and dismisses")
    func didTapApplyDelegatesAndDismisses() {
        // Given
        sut.filter = .stub(status: .alive)

        // When
        sut.didTapApply()

        // Then
        #expect(delegateMock.didApplyFilterCallCount == 1)
        #expect(delegateMock.lastAppliedFilter == .stub(status: .alive))
        #expect(navigatorMock.dismissCallCount == 1)
    }

    @Test("didTapReset clears filter to empty")
    func didTapResetClearsFilter() {
        // Given
        sut.filter = .stub(status: .alive)

        // When
        sut.didTapReset()

        // Then
        #expect(sut.filter == .empty)
    }

    @Test("didTapClose dismisses without applying")
    func didTapCloseDismissesWithoutApplying() {
        // When
        sut.didTapClose()

        // Then
        #expect(delegateMock.didApplyFilterCallCount == 0)
        #expect(navigatorMock.dismissCallCount == 1)
    }
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| ViewModelContract | internal | `Sources/Presentation/{Screen}/ViewModels/` |
| ViewState | internal | `Sources/Presentation/{Screen}/ViewModels/` |
| ViewModel | internal | `Sources/Presentation/{Screen}/ViewModels/` |
| Mock | internal | `Tests/Shared/Mocks/` |

---

## Checklist

- [ ] Create ViewModelContract (`AnyObject` for stateful, plain protocol for stateless)
- [ ] Create ViewState enum with `==` operator (stateful only)
- [ ] Create ViewModel (`@Observable` for stateful, plain `final class` for stateless)
- [ ] Inject UseCases via protocol (contract)
- [ ] Inject NavigatorContract for navigation
- [ ] Inject TrackerContract for tracking
- [ ] Implement `didAppear()` / `didTapOnRetryButton()` as public, `load()` as private
- [ ] Add tracking calls in `didAppear()`, `didSelect()`, `didTapOn...()` methods
- [ ] Guard observable properties with `oldValue` check in `didSet` (search only)
- [ ] Create Mock in `Tests/Shared/Mocks/`
- [ ] Create tests for initial state, success, error, and call verification
- [ ] Run tests

---

## Next steps

- [Create View](create-view.md) — Create SwiftUI View that uses the ViewModel

## See also

- [Create UseCase](create-usecase.md) — UseCase that ViewModel depends on
- [Create Navigator](create-navigator.md) — Navigator for navigation
- [Create Tracker](create-tracker.md) — Tracker for analytics events
