# Stateful Filter ViewModel

Mutable filter with computed properties and delegate pattern. Uses `@Observable` with a mutable `var filter`.

Placeholders: `{Name}` (PascalCase filter entity), `{Screen}` (PascalCase screen), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## Delegate Protocol

```swift
protocol {Name}FilterDelegate: AnyObject, Sendable {
    var currentFilter: {Name}Filter { get }
    func didApplyFilter(_ filter: {Name}Filter)
}
```

## Contract

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

## ViewModel

```swift
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

## View Integration

```swift
struct {Screen}View: View {
    @State private var viewModel: {Screen}ViewModelContract

    var body: some View {
        Form {
            // filter controls bound to viewModel.filter
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Apply") { viewModel.didTapApply() }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { viewModel.didTapClose() }
            }
        }
        .onFirstAppear {
            viewModel.didAppear()
        }
    }
}
```

## Container Factory

```swift
func make{Screen}View(delegate: any {Name}FilterDelegate, navigator: any NavigatorContract) -> some View {
    {Screen}View(
        viewModel: {Screen}ViewModel(
            delegate: delegate,
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
    var filter: {Name}Filter = .empty
    var hasActiveFilters: Bool { filter.activeFilterCount > 0 }
    private(set) var didAppearCallCount = 0
    private(set) var didTapApplyCallCount = 0
    private(set) var didTapResetCallCount = 0
    private(set) var didTapCloseCallCount = 0

    func didAppear() { didAppearCallCount += 1 }
    func didTapApply() { didTapApplyCallCount += 1 }
    func didTapReset() { didTapResetCallCount += 1 }
    func didTapClose() { didTapCloseCallCount += 1 }
}
```

## Delegate Mock (for testing)

```swift
@testable import {AppName}{Feature}

final class {Name}FilterDelegateMock: {Name}FilterDelegate {
    var currentFilter: {Name}Filter = .empty
    private(set) var didApplyFilterCallCount = 0
    private(set) var lastAppliedFilter: {Name}Filter?

    func didApplyFilter(_ filter: {Name}Filter) {
        didApplyFilterCallCount += 1
        lastAppliedFilter = filter
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

    private let delegateMock = {Name}FilterDelegateMock()
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    // MARK: - Initialization

    init() {
        sut = {Screen}ViewModel(
            delegate: delegateMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    // MARK: - Initial State

    @Test("Initial filter matches delegate current filter")
    func initialFilterMatchesDelegate() {
        #expect(sut.filter == delegateMock.currentFilter)
    }

    // MARK: - hasActiveFilters

    @Test("hasActiveFilters produces expected result per scenario", arguments: HasActiveFiltersScenario.all)
    func hasActiveFilters(scenario: HasActiveFiltersScenario) {
        // Given
        sut.filter = scenario.given.filter

        // Then
        #expect(sut.hasActiveFilters == scenario.expected.hasActiveFilters)
    }

    // MARK: - didAppear

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    // MARK: - didTapApply

    @Test("didTapApply produces expected outcome per scenario", arguments: DidTapApplyScenario.all)
    func didTapApply(scenario: DidTapApplyScenario) {
        // Given
        sut.filter = scenario.given.filter

        // When
        sut.didTapApply()

        // Then
        #expect(delegateMock.didApplyFilterCallCount == 1)
        #expect(navigatorMock.dismissCallCount == 1)
        #expect(trackerMock.applyFiltersCallCount == 1)
        #expect(delegateMock.lastAppliedFilter == scenario.expected.appliedFilter)
        #expect(trackerMock.lastAppliedFilterCount == scenario.expected.filterCount)
    }

    // MARK: - didTapReset

    @Test("didTapReset produces expected outcome per scenario", arguments: DidTapResetScenario.all)
    func didTapReset(scenario: DidTapResetScenario) {
        // Given
        sut.filter = scenario.given.filter

        // When
        sut.didTapReset()

        // Then
        #expect(sut.filter == .empty)
        #expect(trackerMock.resetFiltersCallCount == 1)
        #expect(delegateMock.didApplyFilterCallCount == 0)
    }

    // MARK: - didTapClose

    @Test("didTapClose dismisses and tracks without applying filter")
    func didTapCloseDismissesAndTracksWithoutApplyingFilter() {
        // Given
        sut.filter.status = .dead

        // When
        sut.didTapClose()

        // Then
        #expect(navigatorMock.dismissCallCount == 1)
        #expect(trackerMock.closeTappedCallCount == 1)
        #expect(delegateMock.didApplyFilterCallCount == 0)
    }
}

// MARK: - Test Helpers

extension {Screen}ViewModelTests {
    nonisolated struct HasActiveFiltersScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let filter: {Name}Filter
        }

        struct Expected: Sendable {
            let hasActiveFilters: Bool
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [HasActiveFiltersScenario] = [
            HasActiveFiltersScenario(
                testDescription: "Returns true when status is set",
                given: Given(filter: {Name}Filter(status: .alive)),
                expected: Expected(hasActiveFilters: true)
            ),
            HasActiveFiltersScenario(
                testDescription: "Returns false when all fields are empty",
                given: Given(filter: .empty),
                expected: Expected(hasActiveFilters: false)
            ),
        ]
    }

    // DidTapApplyScenario and DidTapResetScenario follow the same pattern
}
```
