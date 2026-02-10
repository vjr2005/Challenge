# Stateful List ViewModel

List load with empty/error states and optional pull-to-refresh. Uses `@Observable` with `private(set) var state`.

Placeholders: `{Name}` (PascalCase entity), `{Screen}` (PascalCase screen), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## ViewState

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

## Contract

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

## ViewModel

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

## View Integration

```swift
struct {Screen}View: View {
    @State private var viewModel: {Screen}ViewModelContract

    var body: some View {
        content
            .onFirstAppear {
                await viewModel.didAppear()
            }
            .refreshable {
                await viewModel.didPullToRefresh()
            }
    }
}
```

## Container Factory

```swift
func make{Screen}ViewModel() -> {Screen}ViewModel {
    {Screen}ViewModel(
        get{Name}sUseCase: Get{Name}sUseCase(repository: {name}Repository),
        refresh{Name}sUseCase: Refresh{Name}sUseCase(repository: {name}Repository),
        navigator: make{Screen}Navigator(),
        tracker: make{Screen}Tracker()
    )
}
```

## Mock

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

## Tests

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
