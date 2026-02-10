# Stateless ViewModel

Navigation and tracking only — no observable state. View uses `let viewModel` instead of `@State private var viewModel`.

Placeholders: `{Name}` (PascalCase screen), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## Contract

```swift
protocol {Name}ViewModelContract {
    func didAppear()
    func didTapOn{Action}()
}
```

No `AnyObject` needed unless View uses `@State`. No `async` — stateless ViewModels are synchronous.

## ViewModel

```swift
/// Not @Observable: no state for the view to observe, only exposes actions.
final class {Name}ViewModel: {Name}ViewModelContract {
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

## View Integration

```swift
struct {Name}View: View {
    /// Not @State: ViewModel has no observable state, just actions.
    let viewModel: {Name}ViewModelContract

    var body: some View {
        Button("Action") {
            viewModel.didTapOn{Action}()
        }
        .onFirstAppear {
            viewModel.didAppear()
        }
    }
}
```

## Container Factory

```swift
func make{Name}ViewModel() -> {Name}ViewModel {
    {Name}ViewModel(
        navigator: make{Name}Navigator(),
        tracker: make{Name}Tracker()
    )
}
```

## Mock

```swift
@testable import {AppName}{Feature}

final class {Name}ViewModelMock: {Name}ViewModelContract, @unchecked Sendable {
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

## Tests

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}ViewModelTests {
    private let navigatorMock = {Name}NavigatorMock()
    private let trackerMock = {Name}TrackerMock()
    private let sut: {Name}ViewModel

    init() {
        sut = {Name}ViewModel(navigator: navigatorMock, tracker: trackerMock)
    }

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    @Test("didTapOn{Action} navigates to {Destination}")
    func didTapOn{Action}NavigatesToDestination() {
        // When
        sut.didTapOn{Action}()

        // Then
        #expect(navigatorMock.navigateTo{Destination}CallCount == 1)
    }

    @Test("didTapOn{Action} tracks button tapped")
    func didTapOn{Action}TracksButtonTapped() {
        // When
        sut.didTapOn{Action}()

        // Then
        #expect(trackerMock.{action}ButtonTappedCallCount == 1)
    }
}
```
