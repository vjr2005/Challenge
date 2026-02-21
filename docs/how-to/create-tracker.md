# How To: Create Tracker

Create screen-specific Trackers for analytics event tracking. Trackers decouple ViewModels from the tracking implementation.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- ViewModel exists (see [Create ViewModel](create-viewmodel.md))
- `TrackerContract` injected into the feature (see [Tracking](../Tracking.md))

## File Structure

```
Features/{Feature}/
├── Sources/
│   └── Presentation/
│       └── {ScreenName}/
│           └── Tracker/
│               ├── {ScreenName}TrackerContract.swift
│               ├── {ScreenName}Tracker.swift
│               └── {ScreenName}Event.swift
└── Tests/
    ├── Unit/
    │   └── Presentation/
    │       └── {ScreenName}/
    │           └── Tracker/
    │               ├── {ScreenName}TrackerTests.swift
    │               └── {ScreenName}EventTests.swift
    └── Shared/
        └── Mocks/
            └── {ScreenName}TrackerMock.swift
```

---

## 1. Define Tracking Events

Identify what events the screen should track. Common patterns:

| Event Type | Method Signature | Example |
|------------|------------------|---------|
| Screen view | `trackScreenViewed()` | Screen appeared |
| Screen view with context | `trackScreenViewed(identifier:)` | Detail screen with ID |
| User action | `track{Action}()` | `trackRetryButtonTapped()` |
| User action with data | `track{Action}({param}:)` | `trackCharacterSelected(identifier:)` |

---

## 2. Create Tracker Contract

Create `Sources/Presentation/{ScreenName}/Tracker/{ScreenName}TrackerContract.swift`:

```swift
protocol {ScreenName}TrackerContract {
    func trackScreenViewed()
}
```

For screens with user interactions:

```swift
protocol {ScreenName}TrackerContract {
    func trackScreenViewed()
    func track{Action}({param}: {Type})
}
```

---

## 3. Create Event Enum

Create `Sources/Presentation/{ScreenName}/Tracker/{ScreenName}Event.swift`:

```swift
import ChallengeCore

enum {ScreenName}Event: TrackingEventContract {
    case screenViewed

    var name: String {
        switch self {
        case .screenViewed:
            "{screen_name}_viewed"
        }
    }
}
```

For events with properties:

```swift
import ChallengeCore

enum {ScreenName}Event: TrackingEventContract {
    case screenViewed
    case {action}({param}: {Type})

    var name: String {
        switch self {
        case .screenViewed:
            "{screen_name}_viewed"
        case .{action}:
            "{action_name}"
        }
    }

    var properties: [String: String] {
        switch self {
        case .{action}(let {param}):
            ["{key}": "\({param})"]
        default:
            [:]
        }
    }
}
```

> **Note:** Events without properties don't need to implement `properties` — the `TrackingEventContract` protocol provides a default empty dictionary.

---

## 4. Create Tracker Implementation

Create `Sources/Presentation/{ScreenName}/Tracker/{ScreenName}Tracker.swift`:

```swift
import ChallengeCore

struct {ScreenName}Tracker: {ScreenName}TrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track({ScreenName}Event.screenViewed)
    }
}
```

For trackers with parametric events:

```swift
import ChallengeCore

struct {ScreenName}Tracker: {ScreenName}TrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track({ScreenName}Event.screenViewed)
    }

    func track{Action}({param}: {Type}) {
        tracker.track({ScreenName}Event.{action}({param}: {param}))
    }
}
```

---

## 5. Create Tracker Mock

Create `Tests/Shared/Mocks/{ScreenName}TrackerMock.swift`:

```swift
@testable import Challenge{Feature}

final class {ScreenName}TrackerMock: {ScreenName}TrackerContract {
    private(set) var screenViewedCallCount = 0

    func trackScreenViewed() {
        screenViewedCallCount += 1
    }
}
```

For mocks with parametric events, capture the arguments:

```swift
@testable import Challenge{Feature}

final class {ScreenName}TrackerMock: {ScreenName}TrackerContract {
    private(set) var screenViewedCallCount = 0
    private(set) var {action}{Param}s: [{Type}] = []

    func trackScreenViewed() {
        screenViewedCallCount += 1
    }

    func track{Action}({param}: {Type}) {
        {action}{Param}s.append({param})
    }
}
```

---

## 6. Create Tracker Tests

Create `Tests/Unit/Presentation/{ScreenName}/Tracker/{ScreenName}TrackerTests.swift`:

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {ScreenName}TrackerTests {
    private let trackerMock = TrackerMock()
    private let sut: {ScreenName}Tracker

    init() {
        sut = {ScreenName}Tracker(tracker: trackerMock)
    }

    @Test("Track screen viewed dispatches correct event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first?.name == "{screen_name}_viewed")
        #expect(trackerMock.trackedEvents.first?.properties == [:])
    }
}
```

---

## 7. Create Event Tests

Create `Tests/Unit/Presentation/{ScreenName}/Tracker/{ScreenName}EventTests.swift`:

```swift
import Testing

@testable import Challenge{Feature}

struct {ScreenName}EventTests {
    @Test("Screen viewed has correct name")
    func screenViewedHasCorrectName() {
        #expect({ScreenName}Event.screenViewed.name == "{screen_name}_viewed")
    }

    @Test("Screen viewed has empty properties")
    func screenViewedHasEmptyProperties() {
        #expect({ScreenName}Event.screenViewed.properties == [:])
    }
}
```

For events with properties:

```swift
@Test("{Action} has correct name")
func {action}HasCorrectName() {
    let event = {ScreenName}Event.{action}({param}: {value})
    #expect(event.name == "{action_name}")
}

@Test("{Action} has correct properties")
func {action}HasCorrectProperties() {
    let event = {ScreenName}Event.{action}({param}: {value})
    #expect(event.properties == ["{key}": "{expected}"])
}
```

---

## 8. Wire Tracker in ViewModel

Add the tracker contract to the ViewModel:

```swift
@Observable
final class {ScreenName}ViewModel: {ScreenName}ViewModelContract {
    private let tracker: {ScreenName}TrackerContract

    init(tracker: {ScreenName}TrackerContract) {
        self.tracker = tracker
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }
}
```

---

## 9. Wire Tracker in Container

Add tracker creation in the Container factory method:

```swift
func make{ScreenName}ViewModel(navigator: any NavigatorContract) -> {ScreenName}ViewModel {
    {ScreenName}ViewModel(
        navigator: {ScreenName}Navigator(navigator: navigator),
        tracker: {ScreenName}Tracker(tracker: tracker)
    )
}
```

---

## 10. Update ViewModel Tests

Replace `TrackerMock` with the screen-specific mock and add tracking assertions:

```swift
@Test("Did appear tracks screen viewed")
func didAppearTracksScreenViewed() async {
    // When
    await sut.didAppear()

    // Then
    #expect(trackerMock.screenViewedCallCount == 1)
}
```

---

## Generate and Verify

```bash
mise x -- tuist generate && mise x -- tuist test --skip-ui-tests
```

---

## See Also

- [Tracking](../Tracking.md) — Architecture overview and event reference
- [Create Tracking Provider](create-tracking-provider.md) — Analytics backend integration
- [Create ViewModel](create-viewmodel.md) — ViewModel that uses the tracker
