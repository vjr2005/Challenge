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
│   ├── {AppName}App.swift           # Minimal entry point
│   ├── AppContainer.swift           # Composition Root (centralized DI)
│   └── RootView.swift               # Root navigation view

Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift       # Public entry point (navigation + deep links)
│   ├── {Feature}Container.swift     # Dependency composition (factories)
│   ├── Navigation/
│   │   ├── {Feature}Navigation.swift       # Navigation destinations
│   │   └── {Feature}DeepLinkHandler.swift  # Deep link handler (feature-level)
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
- Navigation is handled by App using `NavigationPath`

---

## AppContainer (Composition Root)

```swift
// App/Sources/AppContainer.swift
import {AppName}Character
import {AppName}Core
import {AppName}Home
import {AppName}Networking
import {AppName}Shared

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

        features.forEach { $0.registerDeepLinks() }
    }
}
```

**Rules:**
- Centralizes ALL dependency injection in one place
- Creates shared dependencies (HTTPClient, analytics, logger, etc.)
- Injects shared dependencies into features
- Registers deep links automatically
- `features` is stored property (not computed) to avoid duplicate registrations

---

## Feature Container

```swift
// Features/{Feature}/Sources/{Feature}Container.swift
import {AppName}Core
import {AppName}Networking

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

    func make{Name}ListViewModel(router: any RouterContract) -> {Name}ListViewModel {
        {Name}ListViewModel(
            get{Name}sUseCase: Get{Name}sUseCase(repository: repository),
            navigator: {Name}ListNavigator(router: router)
        )
    }

    func make{Name}DetailViewModel(
        identifier: Int,
        router: any RouterContract
    ) -> {Name}DetailViewModel {
        {Name}DetailViewModel(
            identifier: identifier,
            get{Name}UseCase: Get{Name}UseCase(repository: repository),
            navigator: {Name}DetailNavigator(router: router)
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

---

## Feature Protocol (Core Module)

```swift
// Libraries/Core/Sources/Feature/Feature.swift
import SwiftUI

public protocol Feature {
    func registerDeepLinks()
    func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView
}
```

```swift
// Libraries/Core/Sources/Feature/View+FeatureNavigation.swift
import SwiftUI

public extension View {
    func withNavigationDestinations(features: [any Feature], router: any RouterContract) -> some View {
        features.reduce(AnyView(self)) { view, feature in
            feature.applyNavigationDestination(to: view, router: router)
        }
    }
}
```

---

## Navigation Destinations

```swift
// Sources/Navigation/{Feature}Navigation.swift
import {AppName}Core

public enum {Feature}Navigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

**Rules:**
- Conform to `Navigation` protocol (from Core module)
- Use primitive types for parameters (Int, String, Bool, UUID)
- Never pass domain objects - only identifiers

---

## Deep Link Handler (Internal)

```swift
// Sources/Navigation/{Feature}DeepLinkHandler.swift
import {AppName}Core
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandler {
    let scheme = "challenge"
    let host = "{feature}"

    @MainActor
    static func register() {
        DeepLinkRegistry.shared.register(Self())
    }

    func resolve(_ url: URL) -> (any Navigation)? {
        switch url.path {
        case "/list":
            return {Feature}Navigation.list

        case "/detail":
            guard let id = url.queryParameter("id").flatMap(Int.init) else {
                return nil
            }
            return {Feature}Navigation.detail(identifier: id)

        default:
            return nil
        }
    }
}
```

**Note:** DeepLinkHandler is `internal` - external access is through `{Feature}Feature.registerDeepLinks()`.

---

## Feature Struct (Public Entry Point)

```swift
// Sources/{Feature}Feature.swift
import {AppName}Core
import {AppName}Networking
import SwiftUI

public struct {Feature}Feature: Feature {
    // MARK: - Dependencies

    private let container: {Feature}Container

    // MARK: - Init

    public init(httpClient: any HTTPClientContract) {
        self.container = {Feature}Container(httpClient: httpClient)
    }

    // MARK: - Feature Protocol

    public func registerDeepLinks() {
        {Feature}DeepLinkHandler.register()
    }

    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: {Feature}Navigation.self) { navigation in
                self.view(for: navigation, router: router)
            }
        )
    }
}

// MARK: - Private

private extension {Feature}Feature {
    @ViewBuilder
    func view(for navigation: {Feature}Navigation, router: any RouterContract) -> some View {
        switch navigation {
        case .list:
            {Name}ListView(viewModel: container.make{Name}ListViewModel(router: router))
        case .detail(let identifier):
            {Name}DetailView(
                viewModel: container.make{Name}DetailViewModel(
                    identifier: identifier,
                    router: router
                )
            )
        }
    }
}
```

**Rules:**
- **public struct** implementing `Feature` protocol
- **Required httpClient** in init (injected by AppContainer)
- Creates and owns its **Container**
- **registerDeepLinks()** - Public method to register deep links
- **applyNavigationDestination()** - Public method to register navigation destinations
- **view(for:router:)** - Private method, delegates to Container factories

---

## Simple Feature (No Data Layer)

```swift
// Sources/HomeFeature.swift
import {AppName}Core
import SwiftUI

public struct HomeFeature: Feature {
    // MARK: - Dependencies

    private let container: HomeContainer

    // MARK: - Init

    public init() {
        self.container = HomeContainer()
    }

    // MARK: - Feature Protocol

    public func registerDeepLinks() {
        // Home has no deep links
    }

    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(view)
    }

    // MARK: - Factory

    public func makeHomeView(router: any RouterContract) -> some View {
        HomeView(viewModel: container.makeHomeViewModel(router: router))
    }
}
```

```swift
// Sources/HomeContainer.swift
import {AppName}Core

public final class HomeContainer: Sendable {
    // MARK: - Init

    public init() {}

    // MARK: - Factories

    func makeHomeViewModel(router: any RouterContract) -> HomeViewModel {
        HomeViewModel(navigator: HomeNavigator(router: router))
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
| Feature.registerDeepLinks() | **public** | Called from AppContainer |
| Feature.applyNavigationDestination() | **public** | Called via withNavigationDestinations |
| Container factory methods | **internal** | Called by Feature |
| {Feature}Navigation | internal | Not exposed to App layer |
| {Feature}DeepLinkHandler | internal | Accessed via Feature.registerDeepLinks() |
| NavigatorContract | internal | Internal to feature |
| Navigator | internal | Internal implementation |
| Views | internal | Internal UI |

---

## App Integration

### ChallengeApp (Minimal Entry Point)

```swift
// App/Sources/ChallengeApp.swift
import SwiftUI

@main
struct ChallengeApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(features: container.features)
        }
    }
}
```

**Note:** ChallengeApp is minimal - just creates AppContainer and passes features to RootView.

### RootView (Using Features)

```swift
// App/Sources/RootView.swift
import {AppName}Core
import {AppName}Home
import SwiftUI

struct RootView: View {
    let features: [any Feature]
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeFeature()
                .makeHomeView(router: router)
                .withNavigationDestinations(features: features, router: router)
        }
        .onOpenURL { url in
            router.navigate(to: url)
        }
    }
}

#Preview {
    RootView(features: AppContainer().features)
}
```

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
| registerDeepLinks() | Verify deep links are registered correctly |

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
import {AppName}Core
import Foundation

struct HomeNavigator: HomeNavigatorContract {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func navigateToCharacters() {
        // EXTERNAL: uses URL (doesn't import Character feature)
        router.navigate(to: URL(string: "challenge://character/list"))
    }
}
```

**Key Point:** HomeNavigator uses URL for external navigation, so Home feature doesn't need to import Character feature.

---

## Checklist

- [ ] Create `AppContainer.swift` in App/Sources/ as Composition Root
- [ ] Create `{Feature}Container.swift` for dependency composition
- [ ] Create `{Feature}Feature.swift` as struct implementing `Feature` protocol
- [ ] Feature requires `httpClient` in init (no optional default)
- [ ] Feature creates Container in init
- [ ] Container has stored `memoryDataSource` property (source of truth)
- [ ] Container has computed `repository` property
- [ ] Container has factory methods for ViewModels
- [ ] Create internal `Navigation/{Feature}Navigation.swift` conforming to `Navigation` protocol
- [ ] Create internal `{Feature}DeepLinkHandler.swift` in `Sources/Navigation/`
- [ ] Create Navigator for each screen in `Presentation/{Screen}/Navigator/`
- [ ] Views only receive ViewModel
- [ ] Add feature to `AppContainer.features` array
- [ ] `AppContainer.init` registers deep links automatically
- [ ] `ChallengeApp` only creates AppContainer
- [ ] `RootView` receives features and uses `.withNavigationDestinations(features:router:)`
- [ ] **Create feature tests with HTTPClientMock**
