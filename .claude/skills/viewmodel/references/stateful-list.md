# Stateful List ViewModel

List load with empty/error states and optional pull-to-refresh. Uses `@Observable` with `private(set) var state`.

Placeholders: `{Name}` (PascalCase entity), `{Screen}` (PascalCase screen), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## ViewState

```swift
enum {Screen}ViewState {
    case idle
    case loading
    case loaded([{Name}])
    case empty
    case error({Feature}Error)
}
```

> **Note:** For lists with pagination, replace `[{Name}]` with a custom type like `{Name}sPage` that includes pagination metadata (currentPage, totalPages, hasNextPage, etc.).

## Contract

```swift
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
func make{Screen}View(navigator: any NavigatorContract) -> some View {
    {Screen}View(
        viewModel: {Screen}ViewModel(
            get{Name}sUseCase: Get{Name}sUseCase(repository: {name}Repository),
            refresh{Name}sUseCase: Refresh{Name}sUseCase(repository: {name}Repository),
            navigator: {Screen}Navigator(navigator: navigator),
            tracker: make{Screen}Tracker()
        )
    )
}
```

## Mock

```swift
@testable import {AppName}{Feature}

final class {Screen}ViewModelMock: {Screen}ViewModelContract {
    var state: {Screen}ViewState = .idle
    private(set) var didAppearCallCount = 0
    private(set) var didTapOnRetryButtonCallCount = 0
    private(set) var didPullToRefreshCallCount = 0
    private(set) var lastSelectedItem: {Name}?

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

Uses scenario-based parameterized tests. See `/testing` skill for the full scenario struct pattern.

```swift
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewModelTests {
    // MARK: - Properties

    private let getUseCaseMock = Get{Name}sUseCaseMock()
    private let refreshUseCaseMock = Refresh{Name}sUseCaseMock()
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    // MARK: - Initialization

    init() {
        sut = {Screen}ViewModel(
            get{Name}sUseCase: getUseCaseMock,
            refresh{Name}sUseCase: refreshUseCaseMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    // MARK: - Initial State

    @Test("Initial state is idle before loading")
    func initialStateIsIdle() {
        #expect(sut.state == .idle)
    }

    // MARK: - didAppear

    @Test("didAppear produces expected outcome per scenario", arguments: DidAppearScenario.all)
    func didAppear(scenario: DidAppearScenario) async {
        // Given
        getUseCaseMock.result = scenario.given.result

        // When
        await sut.didAppear()

        // Then
        #expect(getUseCaseMock.executeCallCount == 1)
        #expect(trackerMock.screenViewedCallCount == 1)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.fetchErrorDescriptions == scenario.expected.fetchErrorDescriptions)
    }

    // MARK: - didTapOnRetryButton

    @Test("didTapOnRetryButton produces expected outcome per scenario", arguments: DidTapOnRetryButtonScenario.all)
    func didTapOnRetryButton(scenario: DidTapOnRetryButtonScenario) async {
        // Given
        await givenErrorState()
        getUseCaseMock.result = scenario.given.result

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(getUseCaseMock.executeCallCount == 1)
        #expect(trackerMock.retryButtonTappedCallCount == 1)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.fetchErrorDescriptions == scenario.expected.fetchErrorDescriptions)
    }

    // MARK: - didPullToRefresh

    @Test("didPullToRefresh produces expected outcome per scenario", arguments: DidPullToRefreshScenario.all)
    func didPullToRefresh(scenario: DidPullToRefreshScenario) async {
        // Given
        await givenLoadedState()
        refreshUseCaseMock.result = scenario.given.result

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshUseCaseMock.executeCallCount == 1)
        #expect(trackerMock.pullToRefreshTriggeredCallCount == 1)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.refreshErrorDescriptions == scenario.expected.refreshErrorDescriptions)
    }

    // MARK: - didSelect

    @Test("Selecting item navigates to detail and tracks selection")
    func didSelectNavigatesToDetailAndTracksSelection() {
        // Given
        let item = {Name}.stub(id: 42)

        // When
        sut.didSelect(item)

        // Then
        #expect(navigatorMock.navigateToDetailIdentifiers == [42])
        #expect(trackerMock.selectedIdentifiers == [42])
    }

    // MARK: - Helpers

    private func givenErrorState() async {
        getUseCaseMock.result = .failure(.loadFailed())
        await sut.didAppear()
        getUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenLoadedState() async {
        getUseCaseMock.result = .success([.stub()])
        await sut.didAppear()
        getUseCaseMock.reset()
        trackerMock.reset()
    }
}

// MARK: - Test Helpers

extension {Screen}ViewModelTests {
    nonisolated struct DidAppearScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let result: Result<[{Name}], {Feature}Error>
        }

        struct Expected: Sendable {
            let state: {Screen}ViewState
            let fetchErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidAppearScenario] = [
            DidAppearScenario(
                testDescription: "On success sets loaded state",
                given: Given(result: .success([.stub()])),
                expected: Expected(state: .loaded([.stub()]), fetchErrorDescriptions: [])
            ),
            DidAppearScenario(
                testDescription: "On empty result sets empty state",
                given: Given(result: .success([])),
                expected: Expected(state: .empty, fetchErrorDescriptions: [])
            ),
            DidAppearScenario(
                testDescription: "On failure sets error state and tracks error",
                given: Given(result: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    fetchErrorDescriptions: [{Feature}Error.loadFailed().debugDescription]
                )
            ),
        ]
    }

    // DidTapOnRetryButtonScenario and DidPullToRefreshScenario follow the same pattern
}
```
