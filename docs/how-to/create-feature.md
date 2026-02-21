# How To: Create Feature

Create a new feature module with the minimum viable structure: Tuist module, Feature entry point, Container, DeepLinkHandler, and one screen with placeholder `Text`. Integrates into the app.

## Parameters

Gather before starting:

| Parameter | Format | Example |
|-----------|--------|---------|
| Feature | PascalCase | `Episode` |
| Screen | PascalCase | `EpisodeList` |
| Deep link host | lowercase | `episode` |
| Deep link path segment | lowercase, no slash | `list` |

Derived: module name = `Challenge{Feature}`, event prefix = snake_case of Screen.

## File Structure

```
Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift
│   ├── {Feature}Container.swift
│   └── Presentation/
│       ├── Navigation/
│       │   ├── {Feature}IncomingNavigation.swift
│       │   └── {Feature}DeepLinkHandler.swift
│       └── {Screen}/
│           ├── Navigator/
│           │   ├── {Screen}NavigatorContract.swift
│           │   └── {Screen}Navigator.swift
│           ├── Tracker/
│           │   ├── {Screen}TrackerContract.swift
│           │   ├── {Screen}Tracker.swift
│           │   └── {Screen}Event.swift
│           ├── ViewModels/
│           │   ├── {Screen}ViewModelContract.swift
│           │   └── {Screen}ViewModel.swift
│           └── Views/
│               └── {Screen}View.swift
└── Tests/
    ├── Unit/
    │   ├── Feature/
    │   │   └── {Feature}FeatureTests.swift
    │   └── Presentation/
    │       ├── Navigation/
    │       │   └── {Feature}DeepLinkHandlerTests.swift
    │       └── {Screen}/
    │           ├── Navigator/
    │           │   └── {Screen}NavigatorTests.swift
    │           ├── Tracker/
    │           │   ├── {Screen}TrackerTests.swift
    │           │   └── {Screen}EventTests.swift
    │           └── ViewModels/
    │               └── {Screen}ViewModelTests.swift
    └── Shared/
        ├── Mocks/
        │   ├── {Screen}NavigatorMock.swift
        │   └── {Screen}TrackerMock.swift
        └── Stubs/
            └── {Screen}ViewModelStub.swift
```

## Conventions

- **No `@Observable`** on minimal ViewModels (no observable state). Only add when ViewModel has `private(set) var`.
- **No `any` keyword** on internal protocol types. Only on public protocols from other modules (e.g., `any TrackerContract` in Container).
- **No imports** in ViewModel when all types are internal to the module.
- **Deep link paths** are scoped per host — `/list` under `episode` host is independent from `/list` under `character` host.
- **Deep links use path-based URLs** — parameters are embedded in the path (e.g., `challenge://character/detail/42`), never as query items (`?id=42`). Use `url.pathComponents` for parsing.
- Tuist module uses `\(appName)` string interpolation for target names.
- **Features always receive `HTTPClientContract`** as their network dependency — never specific clients like `GraphQLClientContract`. The Container is responsible for creating specific clients (e.g., `GraphQLClient`) internally from the `HTTPClientContract`. This keeps features decoupled from transport details.
- **Features that don't need networking** only receive `tracker: any TrackerContract`.
- **Features that need networking** receive `httpClient: any HTTPClientContract, tracker: any TrackerContract`.

---

## Step 1 — Create Tuist Module

Create `Tuist/ProjectDescriptionHelpers/Modules/{Feature}Module.swift`:

```swift
import ProjectDescription

public let {feature}Module = Module.create(
	directory: "Features/{Feature}",
	dependencies: [
		coreModule.targetDependency,
		designSystemModule.targetDependency,
		resourcesModule.targetDependency,
	],
	testDependencies: [
		coreModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
	]
)
```

Register the module in **`Modules.swift`** — Add `{feature}Module` to the `Modules.all` array. This single registration automatically includes the module's targets in the root project, test schemes, and code coverage.

> **Note:** Tuist automatically detects folders to create targets:
> - `Mocks/` → Target `Challenge{Feature}Mocks`
> - `Tests/Unit/` → Target `Challenge{Feature}Tests`
> - `Tests/Snapshots/` → Target `Challenge{Feature}SnapshotTests`
>
> The contents of `Tests/Shared/` are automatically included in Unit and Snapshot test targets (it does not create its own target).

---

## Step 2 — Create Source Files

Create all source files in this order: IncomingNavigation → DeepLinkHandler → NavigatorContract → Navigator → TrackerContract → Tracker → Event → ViewModelContract → ViewModel → View → Container → Feature.

### {Feature}IncomingNavigation.swift — `Sources/Presentation/Navigation/`

```swift
import ChallengeCore

public enum {Feature}IncomingNavigation: IncomingNavigationContract {
    case main
}
```

### {Feature}DeepLinkHandler.swift — `Sources/Presentation/Navigation/`

```swift
import ChallengeCore
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "{feature}"

    func resolve(_ url: URL) -> (any NavigationContract)? {
        let pathComponents = url.pathComponents
        guard pathComponents.count >= 2 else {
            return nil
        }
        switch pathComponents[1] {
        case "{deepLinkPath}":
            return {Feature}IncomingNavigation.main

        default:
            return nil
        }
    }
}
```

> **Convention:** Deep links use path-based URLs — parameters are embedded in the path (e.g., `challenge://episode/character/42`), never as query items. When the feature grows and needs parameterized routes, parse `pathComponents` (e.g., `pathComponents[2]` for an identifier).

### {Screen}NavigatorContract.swift — `Sources/Presentation/{Screen}/Navigator/`

```swift
protocol {Screen}NavigatorContract {
    // Add navigation methods as the feature grows
}
```

### {Screen}Navigator.swift — `Sources/Presentation/{Screen}/Navigator/`

```swift
import ChallengeCore

struct {Screen}Navigator: {Screen}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }
}
```

### {Screen}TrackerContract.swift — `Sources/Presentation/{Screen}/Tracker/`

```swift
protocol {Screen}TrackerContract {
    func trackScreenViewed()
}
```

### {Screen}Tracker.swift — `Sources/Presentation/{Screen}/Tracker/`

```swift
import ChallengeCore

struct {Screen}Tracker: {Screen}TrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track({Screen}Event.screenViewed)
    }
}
```

### {Screen}Event.swift — `Sources/Presentation/{Screen}/Tracker/`

```swift
import ChallengeCore

enum {Screen}Event: TrackingEventContract {
    case screenViewed

    var name: String {
        switch self {
        case .screenViewed:
            "{eventPrefix}_viewed"
        }
    }

    var properties: [String: String] {
        switch self {
        case .screenViewed:
            [:]
        }
    }
}
```

### {Screen}ViewModelContract.swift — `Sources/Presentation/{Screen}/ViewModels/`

```swift
protocol {Screen}ViewModelContract: AnyObject {
    func didAppear()
}
```

### {Screen}ViewModel.swift — `Sources/Presentation/{Screen}/ViewModels/`

```swift
final class {Screen}ViewModel: {Screen}ViewModelContract {
    private let navigator: {Screen}NavigatorContract
    private let tracker: {Screen}TrackerContract

    init(
        navigator: {Screen}NavigatorContract,
        tracker: {Screen}TrackerContract
    ) {
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }
}
```

### {Screen}View.swift — `Sources/Presentation/{Screen}/Views/`

```swift
import ChallengeDesignSystem
import SwiftUI

struct {Screen}View<ViewModel: {Screen}ViewModelContract>: View {
    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Text("{Feature}")
            .onFirstAppear {
                viewModel.didAppear()
            }
    }
}

/*
#if DEBUG
#Preview {
    {Screen}View(viewModel: {Screen}ViewModelStub())
}
#endif
*/
```

### {Feature}Container.swift — `Sources/`

Without networking (default for minimal features):

```swift
import ChallengeCore

struct {Feature}Container {
    private let tracker: any TrackerContract

    init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    func make{Screen}ViewModel(navigator: any NavigatorContract) -> {Screen}ViewModel {
        {Screen}ViewModel(
            navigator: {Screen}Navigator(navigator: navigator),
            tracker: {Screen}Tracker(tracker: tracker)
        )
    }
}
```

With networking (when DataSources/Repositories are added later):

```swift
import ChallengeCore
import ChallengeNetworking

struct {Feature}Container {
    private let tracker: any TrackerContract
    private let {name}Repository: {Name}RepositoryContract

    init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.tracker = tracker
        // Container creates specific clients internally — features never receive them
        let graphQLClient = GraphQLClient(httpClient: httpClient)
        let remoteDataSource = {Name}GraphQLDataSource(graphQLClient: graphQLClient)
        let memoryDataSource = {Name}MemoryDataSource()
        self.{name}Repository = {Name}Repository(
            remoteDataSource: remoteDataSource,
            memoryDataSource: memoryDataSource
        )
    }

    func make{Screen}ViewModel(navigator: any NavigatorContract) -> {Screen}ViewModel {
        {Screen}ViewModel(
            navigator: {Screen}Navigator(navigator: navigator),
            tracker: {Screen}Tracker(tracker: tracker)
        )
    }
}
```

> **Important:** Features always receive `HTTPClientContract` — never specific clients like `GraphQLClientContract`. The Container is responsible for creating transport-specific clients.

### {Feature}Feature.swift — `Sources/`

Without networking:

```swift
import ChallengeCore
import SwiftUI

public struct {Feature}Feature: FeatureContract {
    private let container: {Feature}Container

    public init(tracker: any TrackerContract) {
        self.container = {Feature}Container(tracker: tracker)
    }

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        {Feature}DeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView({Screen}View(viewModel: container.make{Screen}ViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? {Feature}IncomingNavigation else {
            return nil
        }
        switch navigation {
        case .main:
            return makeMainView(navigator: navigator)
        }
    }
}
```

With networking:

```swift
import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct {Feature}Feature: FeatureContract {
    private let container: {Feature}Container

    public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.container = {Feature}Container(httpClient: httpClient, tracker: tracker)
    }

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        {Feature}DeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView({Screen}View(viewModel: container.make{Screen}ViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? {Feature}IncomingNavigation else {
            return nil
        }
        switch navigation {
        case .main:
            return makeMainView(navigator: navigator)
        }
    }
}
```

---

## Step 3 — Create Test Files

Create all test files in this order: Mocks → Stubs → Unit tests.

### {Screen}NavigatorMock.swift — `Tests/Shared/Mocks/`

```swift
@testable import Challenge{Feature}

final class {Screen}NavigatorMock: {Screen}NavigatorContract {}
```

### {Screen}TrackerMock.swift — `Tests/Shared/Mocks/`

```swift
@testable import Challenge{Feature}

final class {Screen}TrackerMock: {Screen}TrackerContract {
    private(set) var trackScreenViewedCallCount = 0

    func trackScreenViewed() {
        trackScreenViewedCallCount += 1
    }
}
```

### {Screen}ViewModelStub.swift — `Tests/Shared/Stubs/`

```swift
@testable import Challenge{Feature}

final class {Screen}ViewModelStub: {Screen}ViewModelContract {
    func didAppear() {}
}
```

### {Feature}FeatureTests.swift — `Tests/Unit/Feature/`

Without networking:

```swift
import ChallengeCore
import ChallengeCoreMocks
import SwiftUI
import Testing

@testable import Challenge{Feature}

struct {Feature}FeatureTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {Feature}Feature

    init() {
        sut = {Feature}Feature(tracker: TrackerMock())
    }

    @Test("Deep link handler is not nil")
    func deepLinkHandlerIsNotNil() {
        #expect(sut.deepLinkHandler != nil)
    }

    @Test("Make main view returns a view")
    func makeMainViewReturnsView() {
        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        _ = result
    }

    @Test("Resolve main navigation returns view")
    func resolveMainNavigationReturnsView() {
        // When
        let result = sut.resolve({Feature}IncomingNavigation.main, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test("Resolve unknown navigation returns nil")
    func resolveUnknownNavigationReturnsNil() {
        // Given
        struct UnknownNav: NavigationContract {}

        // When
        let result = sut.resolve(UnknownNav(), navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}
```

With networking:

```swift
import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import SwiftUI
import Testing

@testable import Challenge{Feature}

struct {Feature}FeatureTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {Feature}Feature

    init() {
        sut = {Feature}Feature(httpClient: HTTPClientMock(), tracker: TrackerMock())
    }

    // ... same test methods as above ...
}
```

### {Feature}DeepLinkHandlerTests.swift — `Tests/Unit/Presentation/Navigation/`

```swift
import ChallengeCore
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Feature}DeepLinkHandlerTests {
    private let sut = {Feature}DeepLinkHandler()

    @Test("Scheme is challenge")
    func schemeIsChallenge() {
        #expect(sut.scheme == "challenge")
    }

    @Test("Host is {feature}")
    func hostIsCorrect() {
        #expect(sut.host == "{feature}")
    }

    @Test("Resolve main path returns main navigation")
    func resolveMainPathReturnsMainNavigation() throws {
        // Given
        let url = try #require(URL(string: "challenge://{feature}/{deepLinkPath}"))

        // When
        let result = sut.resolve(url)

        // Then
        let navigation = result as? {Feature}IncomingNavigation
        #expect(navigation == .main)
    }

    @Test("Resolve unknown path returns nil")
    func resolveUnknownPathReturnsNil() throws {
        // Given
        let url = try #require(URL(string: "challenge://{feature}/unknown"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }

    @Test("Resolve empty path returns nil")
    func resolveEmptyPathReturnsNil() throws {
        // Given
        let url = try #require(URL(string: "challenge://{feature}"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }
}
```

### {Screen}NavigatorTests.swift — `Tests/Unit/Presentation/{Screen}/Navigator/`

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}NavigatorTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {Screen}Navigator

    init() {
        sut = {Screen}Navigator(navigator: navigatorMock)
    }

    @Test("Init does not crash")
    func initDoesNotCrash() {
        _ = sut
    }
}
```

### {Screen}TrackerTests.swift — `Tests/Unit/Presentation/{Screen}/Tracker/`

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}TrackerTests {
    private let trackerMock = TrackerMock()
    private let sut: {Screen}Tracker

    init() {
        sut = {Screen}Tracker(tracker: trackerMock)
    }

    @Test("Track screen viewed dispatches correct event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "{eventPrefix}_viewed", properties: [:]))
    }
}
```

### {Screen}EventTests.swift — `Tests/Unit/Presentation/{Screen}/Tracker/`

```swift
import Testing

@testable import Challenge{Feature}

struct {Screen}EventTests {
    @Test("Screen viewed has correct name")
    func screenViewedHasCorrectName() {
        #expect({Screen}Event.screenViewed.name == "{eventPrefix}_viewed")
    }

    @Test("Screen viewed has empty properties")
    func screenViewedHasEmptyProperties() {
        #expect({Screen}Event.screenViewed.properties == [:])
    }
}
```

### {Screen}ViewModelTests.swift — `Tests/Unit/Presentation/{Screen}/ViewModels/`

```swift
import Testing

@testable import Challenge{Feature}

struct {Screen}ViewModelTests {
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    init() {
        sut = {Screen}ViewModel(
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    @Test("Did appear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.trackScreenViewedCallCount == 1)
    }
}
```

---

## Step 4 — App Integration

Wire the feature into the app — 2 files to modify:

### `Tuist/ProjectDescriptionHelpers/Modules/AppKitModule.swift`

Add dependency:
```swift
{feature}Module.targetDependency,
```

### `AppKit/Sources/AppContainer.swift`

Three changes:
1. Add import: `import Challenge{Feature}`
2. Add property: `private let {feature}Feature: {Feature}Feature`
3. Initialize in `init`:
   - Without networking: `{feature}Feature = {Feature}Feature(tracker: self.tracker)`
   - With networking: `{feature}Feature = {Feature}Feature(httpClient: self.httpClient, tracker: self.tracker)`
4. Add to `features` array

### `AppKit/Tests/Unit/AppContainerTests.swift`

Increment features count assertion.

---

## Step 5 — Verify

```bash
mise x -- tuist generate && mise x -- tuist test --skip-ui-tests
```

---

## Extending the Feature

| Need | Skill |
|------|-------|
| REST API data source | [Create DataSource](create-datasource.md) |
| Repository + DTO mapping | [Create Repository](create-repository.md) |
| Business logic | [Create UseCase](create-usecase.md) |
| Enhance ViewModel with state | [Create ViewModel](create-viewmodel.md) |
| Enhance View with design system | [Create View](create-view.md) |
| Add more navigation | [Create Navigator](create-navigator.md) |
| Snapshot tests | Snapshot skill |
| UI tests | UI Tests skill |

## See also

- [Create DataSource](create-datasource.md) — Create data access
- [Create Repository](create-repository.md) — Create data abstraction
- [Create UseCase](create-usecase.md) — Create business logic
- [Create ViewModel](create-viewmodel.md) — Create state management
- [Create View](create-view.md) — Create user interface
- [Create Navigator](create-navigator.md) — Create navigation between screens
- [Create Tracker](create-tracker.md) — Create analytics event tracking
