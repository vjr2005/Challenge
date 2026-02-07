# Tracking

The project uses a **3-tier tracking architecture**. Each screen has its own tracker contract, implementation, and events for type-safe, decoupled tracking.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Tracking Architecture                              │
│                                                                             │
│   ViewModel ──► ScreenTrackerContract ──► ScreenTracker ──► TrackerContract │
│                     (Protocol)              (Bridges)         (Core)        │
│                                                                   │        │
│                                                              Tracker       │
│                                                                   │        │
│                                                         ┌─────────┴──────┐ │
│                                                         │   Providers    │ │
│                                                         │ (Console, ...) │ │
│                                                         └────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Three Tiers

| Tier | Component | Module | Purpose |
|------|-----------|--------|---------|
| 1 | `TrackerContract` / `Tracker` | ChallengeCore | Core abstraction that dispatches events to providers |
| 2 | `{Screen}TrackerContract` | Feature | Screen-specific tracking methods (e.g. `trackScreenViewed()`) |
| 3 | `{Screen}Tracker` | Feature | Bridges screen-specific methods to `TrackerContract` using events |

### Comparison with Navigator Pattern

| Aspect | Navigator | Tracker |
|--------|-----------|---------|
| Core contract | `NavigatorContract` | `TrackerContract` |
| Screen contract | `{Screen}NavigatorContract` | `{Screen}TrackerContract` |
| Screen implementation | `{Screen}Navigator` | `{Screen}Tracker` |
| Screen events | N/A | `{Screen}Event` |
| Core dependency | `NavigatorContract` | `TrackerContract` |
| Created in | Container | Container |
| Mock location | `Tests/Shared/Mocks/` | `Tests/Shared/Mocks/` |

## Core Components (ChallengeCore)

### TrackerContract

Protocol that screen trackers use to dispatch events:

```swift
public protocol TrackerContract: Sendable {
    func track(_ event: any TrackingEventContract)
}
```

### Tracker

Concrete implementation that dispatches events to all registered providers:

```swift
public final class Tracker: TrackerContract, Sendable {
    private let providers: [any TrackingProviderContract]

    public init(providers: [any TrackingProviderContract]) {
        self.providers = providers
    }

    public func track(_ event: any TrackingEventContract) {
        for provider in providers {
            provider.track(event)
        }
    }
}
```

### TrackingEventContract

Protocol for tracking events with a name and optional properties:

```swift
public protocol TrackingEventContract: Sendable {
    var name: String { get }
    var properties: [String: String] { get }
}

public extension TrackingEventContract {
    var properties: [String: String] { [:] }
}
```

The default extension provides an empty dictionary, so events without properties can omit the implementation.

### TrackingProviderContract

Protocol for analytics backends (Amplitude, Firebase, etc.). Inherits from `TrackerContract` and adds lifecycle management:

```swift
public protocol TrackingProviderContract: TrackerContract {
    func configure()
}

public extension TrackingProviderContract {
    func configure() {}
}
```

Providers are configured once at app startup before any tracking occurs.

### TrackerContract vs TrackingProviderContract

Both protocols define `track(_:)`, but they serve different roles:

| | `TrackerContract` | `TrackingProviderContract` |
|---|---|---|
| **Role** | Internal dispatch — receives events from features and fans them out to providers | External delivery — sends events to a specific analytics backend |
| **Lifecycle** | No initialization needed | `configure()` called once at app startup for SDK setup |
| **Who implements it** | `Tracker` (single instance) | One struct per backend (Console, Amplitude, Firebase, ...) |
| **Who depends on it** | Screen trackers (`CharacterListTracker`, ...) | `Tracker` (holds an array of providers) |
| **Module** | ChallengeCore | ChallengeCore |

`TrackingProviderContract` inherits from `TrackerContract` because a provider **is** a tracker — it receives events and sends them somewhere. The inheritance avoids duplicating the `track(_:)` requirement while adding `configure()` for SDK initialization that some backends need (e.g. `Amplitude(configuration:)`, `FirebaseApp.configure()`).

```
Features ──► TrackerContract ──► Tracker ──► TrackingProviderContract
                                                 ├── ConsoleTrackingProvider
                                                 ├── AmplitudeTrackingProvider
                                                 └── ...
```

### ConsoleTrackingProvider

Development provider that logs events to the console using `os_log`:

```swift
public struct ConsoleTrackingProvider: TrackingProviderContract {
    private let logger = Logger(subsystem: "com.challenge", category: "Tracking")

    public func track(_ event: any TrackingEventContract) {
        if event.properties.isEmpty {
            logger.info("[\(event.name)]")
        } else {
            let formatted = event.properties
                .sorted { $0.key < $1.key }
                .map { "\($0.key): \($0.value)" }
                .joined(separator: ", ")
            logger.info("[\(event.name)] \(formatted)")
        }
    }
}
```

## Screen-Specific Tracking (Feature Modules)

Each screen has 3 files in a `Tracker/` directory alongside its `Navigator/` and `ViewModels/` directories.

### Screen Tracker Contract

Defines screen-specific tracking methods:

```swift
protocol CharacterListTrackerContract {
    func trackScreenViewed()
    func trackCharacterSelected(identifier: Int)
    func trackSearchPerformed(query: String)
}
```

### Screen Tracker Implementation

Bridges screen methods to `TrackerContract` using event enums:

```swift
import ChallengeCore

struct CharacterListTracker: CharacterListTrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(CharacterListEvent.screenViewed)
    }

    func trackCharacterSelected(identifier: Int) {
        tracker.track(CharacterListEvent.characterSelected(identifier: identifier))
    }

    func trackSearchPerformed(query: String) {
        tracker.track(CharacterListEvent.searchPerformed(query: query))
    }
}
```

### Screen Event Enum

Type-safe events with computed `name` and `properties`:

```swift
import ChallengeCore

enum CharacterListEvent: TrackingEventContract {
    case screenViewed
    case characterSelected(identifier: Int)
    case searchPerformed(query: String)

    var name: String {
        switch self {
        case .screenViewed:
            "character_list_viewed"
        case .characterSelected:
            "character_selected"
        case .searchPerformed:
            "search_performed"
        }
    }

    var properties: [String: String] {
        switch self {
        case .characterSelected(let identifier):
            ["id": "\(identifier)"]
        case .searchPerformed(let query):
            ["query": query]
        default:
            [:]
        }
    }
}
```

## Dependency Injection

### AppContainer

Creates the `Tracker` with providers and injects it into all features:

```swift
public struct AppContainer: Sendable {
    public let tracker: any TrackerContract

    public init(tracker: (any TrackerContract)? = nil) {
        let providers = Self.makeTrackingProviders()
        providers.forEach { $0.configure() }
        self.tracker = tracker ?? Tracker(providers: providers)

        homeFeature = HomeFeature(tracker: self.tracker)
        characterFeature = CharacterFeature(httpClient: self.httpClient, tracker: self.tracker)
        systemFeature = SystemFeature(tracker: self.tracker)
    }

    private static func makeTrackingProviders() -> [any TrackingProviderContract] {
        [ConsoleTrackingProvider()]
    }
}
```

### Feature Container

Creates screen-specific trackers, same pattern as navigators:

```swift
func makeCharacterListViewModel(navigator: any NavigatorContract) -> CharacterListViewModel {
    CharacterListViewModel(
        getCharactersPageUseCase: makeGetCharactersPageUseCase(),
        searchCharactersPageUseCase: makeSearchCharactersPageUseCase(),
        navigator: CharacterListNavigator(navigator: navigator),
        tracker: CharacterListTracker(tracker: tracker)
    )
}
```

## Event Naming Conventions

| Pattern | Example | Description |
|---------|---------|-------------|
| `{screen}_viewed` | `character_list_viewed` | Screen appeared |
| `{action}` | `character_selected` | User interaction |
| `{screen}_{action}` | `character_list_retry_tapped` | Screen-specific action |

Properties use snake_case keys with string values.

## Registered Events

| Screen | Event | Properties |
|--------|-------|------------|
| CharacterList | `character_list_viewed` | — |
| | `character_selected` | `id` |
| | `search_performed` | `query` |
| | `character_list_retry_tapped` | — |
| | `character_list_pull_to_refresh` | — |
| | `character_list_load_more_tapped` | — |
| CharacterDetail | `character_detail_viewed` | `id` |
| Home | `home_viewed` | — |
| NotFound | `not_found_viewed` | — |

## Testing

### Screen Tracker Tests

Inject `TrackerMock` (from `ChallengeCoreMocks`) and verify correct events are dispatched:

```swift
import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterListTrackerTests {
    private let trackerMock = TrackerMock()
    private let sut: CharacterListTracker

    init() {
        sut = CharacterListTracker(tracker: trackerMock)
    }

    @Test("Track screen viewed dispatches correct event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first?.name == "character_list_viewed")
        #expect(trackerMock.trackedEvents.first?.properties == [:])
    }
}
```

### Event Tests

Verify `name` and `properties` for each event case:

```swift
@Test("Screen viewed has correct name")
func screenViewedHasCorrectName() {
    #expect(CharacterListEvent.screenViewed.name == "character_list_viewed")
}

@Test("Character selected has correct properties")
func characterSelectedHasCorrectProperties() {
    let event = CharacterListEvent.characterSelected(identifier: 42)
    #expect(event.properties == ["id": "42"])
}
```

### ViewModel Tracking Assertions

Verify ViewModels call the correct tracker methods:

```swift
@Test("Did appear tracks screen viewed")
func didAppearTracksScreenViewed() async {
    // When
    await sut.didAppear()

    // Then
    #expect(trackerMock.screenViewedCallCount == 1)
}
```

### Tracker Mock

Each screen has its own mock in `Tests/Shared/Mocks/`:

```swift
@testable import ChallengeCharacter

final class CharacterListTrackerMock: CharacterListTrackerContract {
    private(set) var screenViewedCallCount = 0
    private(set) var selectedIdentifiers: [Int] = []
    private(set) var searchedQueries: [String] = []

    func trackScreenViewed() {
        screenViewedCallCount += 1
    }

    func trackCharacterSelected(identifier: Int) {
        selectedIdentifiers.append(identifier)
    }

    func trackSearchPerformed(query: String) {
        searchedQueries.append(query)
    }
}
```

## See Also

- [Create Tracker](how-to/create-tracker.md) — Step-by-step guide for screen-specific trackers
- [Create Tracking Provider](how-to/create-tracking-provider.md) — Step-by-step guide for analytics backends
- [Dependency Injection](DependencyInjection.md) — Container wiring
- [Architecture](Architecture.md) — Layer overview
