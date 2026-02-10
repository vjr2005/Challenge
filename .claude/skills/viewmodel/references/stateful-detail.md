# Stateful Detail ViewModel

Single item load with optional pull-to-refresh. Uses `@Observable` with `private(set) var state`.

Placeholders: `{Name}` (PascalCase entity), `{Screen}` (PascalCase screen), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## ViewState

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

## Contract

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

## ViewModel

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

> **Note:** `refresh()` does NOT set `state = .loading` — the current content stays visible during pull-to-refresh.

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
func make{Screen}ViewModel(identifier: Int) -> {Screen}ViewModel {
    {Screen}ViewModel(
        identifier: identifier,
        get{Name}UseCase: Get{Name}UseCase(repository: {name}Repository),
        refresh{Name}UseCase: Refresh{Name}UseCase(repository: {name}Repository),
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

## Tests

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
