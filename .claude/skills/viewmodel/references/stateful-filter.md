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
func make{Screen}ViewModel(delegate: any {Name}FilterDelegate) -> {Screen}ViewModel {
    {Screen}ViewModel(
        delegate: delegate,
        navigator: make{Screen}Navigator(),
        tracker: make{Screen}Tracker()
    )
}
```

## Mock

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

## Delegate Mock (for testing)

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

## Tests

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
