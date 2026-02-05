# How To: Create Tracking Provider

Create a tracking provider to send events to an analytics backend (Amplitude, Firebase, etc.).

## Prerequisites

- Tracking system configured in the project (see [Tracking](../Tracking.md))
- Analytics SDK added as a dependency (see [Tuist Configuration](../Tuist.md))

## File Structure

```
Libraries/Core/
├── Sources/
│   └── Tracking/
│       └── Providers/
│           ├── TrackingProviderContract.swift  (already exists)
│           ├── ConsoleTrackingProvider.swift   (already exists)
│           └── {Name}TrackingProvider.swift
└── Tests/
    └── Unit/
        └── Tracking/
            └── {Name}TrackingProviderTests.swift
```

---

## 1. Create the Provider

Create `Libraries/Core/Sources/Tracking/Providers/{Name}TrackingProvider.swift`:

```swift
import ChallengeCore

struct {Name}TrackingProvider: TrackingProviderContract {
    func configure() {
        // Initialize the analytics SDK
    }

    func track(_ event: any TrackingEventContract) {
        // Forward the event to the analytics backend
    }
}
```

### `configure()`

Called once at app startup before any `track(_:)` call. Use it to initialize the SDK, set API keys, or configure default properties. If the backend requires no initialization, omit the method — `TrackingProviderContract` provides a default empty implementation.

### `track(_:)`

Called for every event dispatched through `Tracker`. Maps `TrackingEventContract.name` and `TrackingEventContract.properties` to the backend's API.

---

## 2. Register in AppContainer

Add the provider to `AppKit/Sources/AppContainer.swift`:

```swift
private extension AppContainer {
    static func makeTrackingProviders() -> [any TrackingProviderContract] {
        [
            ConsoleTrackingProvider(),
            {Name}TrackingProvider()
        ]
    }
}
```

The order in the array determines the dispatch order. `Tracker` calls `track(_:)` on each provider sequentially.

---

## 3. Create Tests

Create `Libraries/Core/Tests/Unit/Tracking/{Name}TrackingProviderTests.swift`:

```swift
import Testing

@testable import ChallengeCore

struct {Name}TrackingProviderTests {
    private let sut = {Name}TrackingProvider()

    @Test("Configures without crashing")
    func configuresWithoutCrashing() {
        // When / Then
        sut.configure()
    }

    @Test("Tracks event without properties without crashing")
    func tracksEventWithoutProperties() {
        // Given
        let event = TestEvent(name: "screen_viewed")

        // When / Then
        sut.track(event)
    }

    @Test("Tracks event with properties without crashing")
    func tracksEventWithProperties() {
        // Given
        let event = TestEvent(name: "button_tapped", properties: ["id": "42"])

        // When / Then
        sut.track(event)
    }
}

// MARK: - Test Helpers

private struct TestEvent: TrackingEventContract {
    let name: String
    var properties: [String: String] = [:]
}
```

---

## Generate and Verify

```bash
mise x -- tuist test
```

---

## Example: Amplitude

```swift
import AmplitudeSwift
import ChallengeCore

struct AmplitudeTrackingProvider: TrackingProviderContract {
    private let amplitude: Amplitude

    init(apiKey: String) {
        amplitude = Amplitude(
            configuration: Configuration(apiKey: apiKey)
        )
    }

    func configure() {
        // Amplitude initializes during init.
        // Use configure() for additional setup if needed,
        // e.g. setting user properties or default event properties.
    }

    func track(_ event: any TrackingEventContract) {
        amplitude.track(
            eventType: event.name,
            eventProperties: event.properties
        )
    }
}
```

Registration in `AppContainer`:

```swift
private extension AppContainer {
    static func makeTrackingProviders() -> [any TrackingProviderContract] {
        [
            ConsoleTrackingProvider(),
            AmplitudeTrackingProvider(apiKey: AppEnvironment.current.amplitude.apiKey)
        ]
    }
}
```

---

## See Also

- [Tracking](../Tracking.md) — Architecture overview
- [Create Tracker](create-tracker.md) — Screen-specific trackers
