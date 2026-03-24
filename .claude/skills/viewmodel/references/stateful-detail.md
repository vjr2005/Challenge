# Stateful Detail ViewModel

Single item load with optional pull-to-refresh. Uses `@Observable` with `private(set) var state`.

Placeholders: `{Name}` (PascalCase entity), `{Screen}` (PascalCase screen), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## ViewState

```swift
enum {Screen}ViewState {
    case idle
    case loading
    case loaded({Name})
    case error({Feature}Error)
}
```

## Contract

```swift
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
func make{Screen}View(identifier: Int, navigator: any NavigatorContract) -> some View {
    {Screen}View(
        viewModel: {Screen}ViewModel(
            identifier: identifier,
            get{Name}UseCase: Get{Name}UseCase(repository: {name}Repository),
            refresh{Name}UseCase: Refresh{Name}UseCase(repository: {name}Repository),
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
    private(set) var didTapOnBackCallCount = 0

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

Uses scenario-based parameterized tests. See `/testing` skill for the full scenario struct pattern.

```swift
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewModelTests {
    // MARK: - Properties

    private let identifier = 1
    private let getUseCaseMock = Get{Name}UseCaseMock()
    private let refreshUseCaseMock = Refresh{Name}UseCaseMock()
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    // MARK: - Initialization

    init() {
        sut = {Screen}ViewModel(
            identifier: identifier,
            get{Name}UseCase: getUseCaseMock,
            refresh{Name}UseCase: refreshUseCaseMock,
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
        #expect(getUseCaseMock.lastRequestedIdentifier == identifier)
        #expect(trackerMock.screenViewedIdentifiers == [identifier])
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.loadErrorDescriptions == scenario.expected.loadErrorDescriptions)
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
        #expect(trackerMock.loadErrorDescriptions == scenario.expected.loadErrorDescriptions)
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

    @Test("didPullToRefresh keeps loaded state visible during network request")
    func didPullToRefreshKeepsLoadedStateDuringRequest() async {
        // Given
        await givenLoadedState()
        refreshUseCaseMock.result = .success(.stub())

        var statesDuringRefresh: [{Screen}ViewState] = []
        refreshUseCaseMock.onExecute = { [weak sut] in
            guard let sut else { return }
            statesDuringRefresh.append(sut.state)
        }

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(statesDuringRefresh.first == .loaded(.stub()))
    }

    // MARK: - didTapOnBack

    @Test("didTapOnBack navigates back and tracks event")
    func didTapOnBack() {
        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
        #expect(trackerMock.backButtonTappedCallCount == 1)
    }

    // MARK: - Helpers

    private func givenErrorState() async {
        getUseCaseMock.result = .failure(.loadFailed())
        await sut.didAppear()
        getUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenLoadedState() async {
        getUseCaseMock.result = .success(.stub())
        await sut.didAppear()
        getUseCaseMock.reset()
        trackerMock.reset()
    }
}

// MARK: - Test Helpers

extension {Screen}ViewModelTests {
    nonisolated struct DidAppearScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let result: Result<{Name}, {Feature}Error>
        }

        struct Expected: Sendable {
            let state: {Screen}ViewState
            let loadErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidAppearScenario] = [
            DidAppearScenario(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(result: .success(.stub())),
                expected: Expected(state: .loaded(.stub()), loadErrorDescriptions: [])
            ),
            DidAppearScenario(
                testDescription: "On failure sets error state and tracks load error",
                given: Given(result: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    loadErrorDescriptions: [{Feature}Error.loadFailed().debugDescription]
                )
            ),
        ]
    }

    // DidTapOnRetryButtonScenario and DidPullToRefreshScenario follow the same pattern
}
```
