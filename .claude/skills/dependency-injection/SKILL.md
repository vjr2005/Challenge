---
name: dependency-injection
description: Creates Features for dependency injection. Use when creating features, exposing public entry points, or wiring up dependencies.
---

# Skill: Dependency Injection

Guide for creating dependency injection with Composition Root pattern.

## When to use this skill

- Create a Feature struct for a module
- Create a Container for dependency composition
- Expose a public entry point for the feature
- Wire up dependencies with stored properties for stateful objects

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## Architecture Overview

```
ChallengeApp
    │
    └── AppContainer (Composition Root)
        │
        ├── httpClient: HTTPClientContract
        │
        └── features: [Feature]
            ├── CharacterFeature (navigation + deep links)
            │   └── CharacterContainer (DI composition)
            │       ├── repository
            │       ├── makeCharacterListViewModel()
            │       └── makeCharacterDetailViewModel()
            │
            └── HomeFeature (navigation)
                └── HomeContainer (DI composition)
                    └── makeHomeViewModel()
```

## File structure

```
App/
├── Sources/
│   ├── {AppName}App.swift              # Minimal entry point
│   ├── AppContainer.swift              # Composition Root (centralized DI)
│   ├── Navigation/
│   │   └── AppNavigationRedirect.swift # Connects features via redirects
│   └── Presentation/
│       └── Views/
│           └── RootContainerView.swift # Root navigation view

Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift       # Public entry point (navigation + deep links)
│   ├── {Feature}Container.swift     # Dependency composition (factories)
│   ├── Navigation/
│   │   ├── {Feature}IncomingNavigation.swift  # Destinations this feature handles
│   │   ├── {Feature}OutgoingNavigation.swift  # Destinations to other features
│   │   └── {Feature}DeepLinkHandler.swift     # Deep link handler
│   ├── Domain/
│   ├── Data/
│   └── Presentation/
│       ├── {Name}List/
│       │   ├── Navigator/
│       │   │   ├── {Name}ListNavigatorContract.swift
│       │   │   └── {Name}ListNavigator.swift
│       │   ├── Views/
│       │   └── ViewModels/
│       └── {Name}Detail/
│           ├── Navigator/
│           │   ├── {Name}DetailNavigatorContract.swift
│           │   └── {Name}DetailNavigator.swift
│           ├── Views/
│           └── ViewModels/
└── Tests/
    └── Feature/
        └── {Feature}FeatureTests.swift
```

**Key Concepts:**
- **AppContainer**: Composition Root - creates shared dependencies (HTTPClient) and all features
- **{Feature}Container**: Handles dependency composition (repositories, factories)
- **{Feature}Feature**: Handles navigation and deep links, delegates DI to Container
- Views receive **only ViewModel** via init
- Navigation is handled by App using `NavigationCoordinator`

---

## AppContainer (Composition Root)

```swift
// App/Sources/AppContainer.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import ChallengeNetworking
import SwiftUI

struct AppContainer: Sendable {
    // MARK: - Shared Dependencies

    let httpClient: any HTTPClientContract

    // MARK: - Features

    let features: [any Feature]

    // MARK: - Init

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: AppEnvironment.current.rickAndMorty.baseURL
        )

        self.features = [
            CharacterFeature(httpClient: self.httpClient),
            HomeFeature()
        ]
    }

    func handle(url: URL, navigator: any NavigatorContract) {
        for feature in features {
            if let navigation = feature.deepLinkHandler?.resolve(url) {
                navigator.navigate(to: navigation)
                return
            }
        }
    }

    // MARK: - Factory Methods

    func makeRootView(navigator: any NavigatorContract) -> some View {
        HomeFeature().makeHomeView(navigator: navigator)
    }
}
```

**Rules:**
- Centralizes ALL dependency injection in one place
- Creates shared dependencies (HTTPClient, analytics, logger, etc.)
- Injects shared dependencies into features
- Handles deep links via feature handlers
- `features` is stored property (not computed) to maintain consistency

---

## Feature Container

```swift
// Features/{Feature}/Sources/{Feature}Container.swift
import ChallengeCore
import ChallengeNetworking

public final class {Feature}Container: Sendable {
    // MARK: - Dependencies

    private let httpClient: any HTTPClientContract
    private let memoryDataSource = {Name}MemoryDataSource()

    // MARK: - Init

    public init(httpClient: any HTTPClientContract) {
        self.httpClient = httpClient
    }

    // MARK: - Repository

    private var repository: any {Name}RepositoryContract {
        {Name}Repository(
            remoteDataSource: {Name}RemoteDataSource(httpClient: httpClient),
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Factories

    func make{Name}ListViewModel(navigator: any NavigatorContract) -> {Name}ListViewModel {
        {Name}ListViewModel(
            get{Name}sUseCase: Get{Name}sUseCase(repository: repository),
            navigator: {Name}ListNavigator(navigator: navigator)
        )
    }

    func make{Name}DetailViewModel(
        identifier: Int,
        navigator: any NavigatorContract
    ) -> {Name}DetailViewModel {
        {Name}DetailViewModel(
            identifier: identifier,
            get{Name}UseCase: Get{Name}UseCase(repository: repository),
            navigator: {Name}DetailNavigator(navigator: navigator)
        )
    }
}
```

**Rules:**
- **public final class** with `Sendable` conformance
- Receives `httpClient` from Feature (injected by AppContainer)
- Owns **stored memoryDataSource** (source of truth for caching)
- Has **computed repository** (uses shared memoryDataSource)
- Contains all **factory methods** for ViewModels
- Factory methods receive `navigator: any NavigatorContract`

---

## Feature Protocol (Core Module)

```swift
// Libraries/Core/Sources/Feature/Feature.swift
import SwiftUI

public protocol Feature {
    /// The deep link handler for this feature (optional).
    var deepLinkHandler: (any DeepLinkHandler)? { get }

    /// Creates the main view for this feature.
    func makeMainView(navigator: any NavigatorContract) -> AnyView

    /// Resolves a navigation destination to a view.
    /// Returns nil if this feature doesn't handle the given navigation.
    func resolve(_ navigation: any Navigation, navigator: any NavigatorContract) -> AnyView?
}

public extension Feature {
    var deepLinkHandler: (any DeepLinkHandler)? { nil }
}
```

**Notes:**
- `deepLinkHandler` is optional with default `nil` implementation
- `makeMainView()` creates the feature's default entry point view
- `resolve()` returns a view for the navigation or `nil` if not handled

---

## Navigation Destinations

```swift
// Sources/Navigation/{Feature}IncomingNavigation.swift
import ChallengeCore

public enum {Feature}IncomingNavigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

```swift
// Sources/Navigation/{Feature}OutgoingNavigation.swift
import ChallengeCore

public enum {Feature}OutgoingNavigation: Navigation {
    case settings  // Navigates to Settings feature
}
```

**Rules:**
- Conform to `Navigation` protocol (from Core module)
- Use primitive types for parameters (Int, String, Bool, UUID)
- Never pass domain objects - only identifiers
- **IncomingNavigation**: Destinations this feature handles
- **OutgoingNavigation**: Destinations to other features (connected via AppNavigationRedirect)

---

## Deep Link Handler (Optional)

Only create a DeepLinkHandler if the feature needs to handle deep links. Features without deep link handling can omit this entirely.

```swift
// Sources/Navigation/{Feature}DeepLinkHandler.swift
import ChallengeCore
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandler {
    let scheme = "challenge"
    let host = "{feature}"

    func resolve(_ url: URL) -> (any Navigation)? {
        switch url.path {
        case "/list":
            return {Feature}IncomingNavigation.list

        case "/detail":
            guard let id = url.queryParameter("id").flatMap(Int.init) else {
                return nil
            }
            return {Feature}IncomingNavigation.detail(identifier: id)

        default:
            return nil
        }
    }
}
```

**Note:** DeepLinkHandler returns `IncomingNavigation` only. If a feature doesn't handle deep links, don't implement `deepLinkHandler` - the default `nil` implementation will be used.

---

## Feature Struct (Public Entry Point)

```swift
// Sources/{Feature}Feature.swift
import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct {Feature}Feature: Feature {
    // MARK: - Dependencies

    private let container: {Feature}Container

    // MARK: - Init

    public init(httpClient: any HTTPClientContract) {
        self.container = {Feature}Container(httpClient: httpClient)
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandler)? {
        {Feature}DeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView({Name}ListView(
            viewModel: container.make{Name}ListViewModel(navigator: navigator)
        ))
    }

    public func resolve(
        _ navigation: any Navigation,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? {Feature}IncomingNavigation else {
            return nil
        }
        switch navigation {
        case .list:
            return makeMainView(navigator: navigator)
        case .detail(let identifier):
            return AnyView({Name}DetailView(
                viewModel: container.make{Name}DetailViewModel(
                    identifier: identifier,
                    navigator: navigator
                )
            ))
        }
    }
}
```

**Rules:**
- **public struct** implementing `Feature` protocol
- **Required httpClient** in init (injected by AppContainer)
- Creates and owns its **Container**
- **deepLinkHandler** property (optional) - Returns handler instance if feature handles deep links
- **makeMainView()** - Returns the default entry point view
- **resolve()** - Returns view for navigation or `nil` if not handled

---

## Simple Feature (No Data Layer)

```swift
// Sources/HomeFeature.swift
import ChallengeCore
import SwiftUI

public struct HomeFeature: Feature {
    // MARK: - Dependencies

    private let container: HomeContainer

    // MARK: - Init

    public init() {
        self.container = HomeContainer()
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandler)? {
        HomeDeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(HomeView(viewModel: container.makeHomeViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any Navigation,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? HomeIncomingNavigation else {
            return nil
        }
        switch navigation {
        case .main:
            return makeMainView(navigator: navigator)
        }
    }
}
```

```swift
// Sources/HomeContainer.swift
import ChallengeCore

public final class HomeContainer: Sendable {
    // MARK: - Init

    public init() {}

    // MARK: - Factories

    func makeHomeViewModel(navigator: any NavigatorContract) -> HomeViewModel {
        HomeViewModel(navigator: HomeNavigator(navigator: navigator))
    }
}
```

**Note:** Even simple features use Container for architectural consistency and future extensibility.

---

## Dependency Patterns

| Type | Pattern | Reason |
|------|---------|--------|
| HTTPClient | Required init parameter | Injected by AppContainer |
| Container | Created in Feature init | Owns dependency composition |
| MemoryDataSource | Instance property in Container (`let`) | Maintains cache state |
| Repository | Computed property in Container (`var`) | Uses shared memoryDataSource |
| Navigator | Factory method (inline) | New instance per ViewModel |
| ViewModel | Factory method | New instance per navigation |
| UseCase | Created inline | Stateless |

---

## Visibility Summary

| Component | Visibility | Reason |
|-----------|------------|--------|
| Contract (Protocol) | **public** | API for consumers, enables DI |
| Implementation (Class) | **public** / **open** | Direct instantiation allowed |
| {Feature}Feature | **public** | Entry point struct |
| {Feature}Container | **public** | Created by Feature |
| Feature.deepLinkHandler | **public** (optional) | Used by AppContainer if feature handles deep links |
| Feature.applyNavigationDestination() | **public** | Called via withNavigationDestinations |
| Container factory methods | **internal** | Called by Feature |
| {Feature}IncomingNavigation | **public** | Used by AppNavigationRedirect |
| {Feature}OutgoingNavigation | **public** | Used by AppNavigationRedirect |
| {Feature}DeepLinkHandler | internal | Accessed via Feature.deepLinkHandler |
| NavigatorContract | internal | Internal to feature |
| Navigator | internal | Internal implementation |
| Views | internal | Internal UI |

---

## App Integration

### ChallengeApp (Minimal Entry Point)

```swift
// App/Sources/ChallengeApp.swift
import ChallengeAppKit
import SwiftUI

@main
struct ChallengeApp: App {
    private let appContainer = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootContainerView(appContainer: appContainer)
        }
    }
}
```

**Note:** ChallengeApp is minimal - just creates AppContainer and uses RootContainerView from `ChallengeAppKit`.

### RootContainerView (Using Features)

```swift
// AppKit/Sources/Presentation/Views/RootContainerView.swift
import ChallengeCore
import SwiftUI

public struct RootContainerView: View {
    public let appContainer: AppContainer

    @State private var navigationCoordinator: NavigationCoordinator

    public init(appContainer: AppContainer) {
        self.appContainer = appContainer
        _navigationCoordinator = State(initialValue: NavigationCoordinator(redirector: AppNavigationRedirect()))
    }

    public var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            appContainer.makeRootView(navigator: navigationCoordinator)
                .navigationDestination(for: AnyNavigation.self) { navigation in
                    appContainer.resolve(navigation.wrapped, navigator: navigationCoordinator)
                }
        }
        .onOpenURL { url in
            appContainer.handle(url: url, navigator: navigationCoordinator)
        }
    }
}

#Preview {
    RootContainerView(appContainer: AppContainer())
}
```

**Key Changes:**
- Located in `AppKit` module (not `App`) for testability without TEST_HOST
- Uses `AnyNavigation` wrapper for type-erased navigation
- `appContainer.resolve()` iterates features to find handler

---

## Testing Features

Features are tested through their **public interface**. Factory methods are internal to Container.

### File Structure

```
Features/{Feature}/
└── Tests/
    └── Feature/
        └── {Feature}FeatureTests.swift
```

### What to Test

| Test | Purpose |
|------|---------|
| Init with HTTPClient | Verify feature initializes without crashing |
| applyNavigationDestination | Verify navigation destinations are registered |
| deepLinkHandler | Verify deep links are resolved correctly |

**Note:** Factory methods are internal to Container. Test them indirectly through ViewModel tests, Repository tests, and DeepLinkHandler tests.

For complete test examples, see [examples.md](examples.md).

---

## Example: Home Feature (External Navigation)

For features that navigate **externally** to other features:

```swift
// Sources/Presentation/Home/Navigator/HomeNavigatorContract.swift
protocol HomeNavigatorContract {
    func navigateToCharacters()
}
```

```swift
// Sources/Presentation/Home/Navigator/HomeNavigator.swift
import ChallengeCore

struct HomeNavigator: HomeNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToCharacters() {
        // Uses OutgoingNavigation - redirected by AppNavigationRedirect
        navigator.navigate(to: HomeOutgoingNavigation.characters)
    }
}
```

**Key Point:** HomeNavigator uses `OutgoingNavigation`, which is connected to `CharacterIncomingNavigation.list` via `AppNavigationRedirect`.

---

## Checklist

- [ ] Create `AppContainer.swift` in `AppKit/Sources/` as Composition Root
- [ ] Create `AppNavigationRedirect.swift` in `AppKit/Sources/Presentation/Navigation/`
- [ ] Create `RootContainerView.swift` in `AppKit/Sources/Presentation/Views/`
- [ ] Create `{Feature}Container.swift` for dependency composition
- [ ] Create `{Feature}Feature.swift` as struct implementing `Feature` protocol
- [ ] Feature requires `httpClient` in init (no optional default)
- [ ] Feature creates Container in init
- [ ] Feature implements `makeMainView(navigator:)` returning default entry point
- [ ] Feature implements `resolve(_:navigator:)` returning view or `nil`
- [ ] Container has stored `memoryDataSource` property (source of truth)
- [ ] Container has computed `repository` property
- [ ] Container has factory methods receiving `navigator: any NavigatorContract`
- [ ] Create `{Feature}IncomingNavigation.swift` in `Presentation/Navigation/`
- [ ] Create `{Feature}OutgoingNavigation.swift` for cross-feature navigation (if needed)
- [ ] Create `{Feature}DeepLinkHandler.swift` (only if feature handles deep links)
- [ ] Create Navigator for each screen in `Presentation/{Screen}/Navigator/`
- [ ] Views only receive ViewModel
- [ ] Add feature to `AppContainer.features` array
- [ ] `AppContainer` has `resolve(_:navigator:)` iterating features
- [ ] `AppContainer` has `handle(url:navigator:)` for deep links
- [ ] `AppContainer` has `makeRootView(navigator:)` factory method
- [ ] `ChallengeApp` imports `ChallengeAppKit` and uses `RootContainerView`
- [ ] `RootContainerView` uses `.navigationDestination(for: AnyNavigation.self)`
- [ ] **Create feature tests**
