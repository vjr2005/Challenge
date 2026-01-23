---
name: dependency-injection
description: Creates Features for dependency injection. Use when creating features, exposing public entry points, or wiring up dependencies.
---

# Skill: Dependency Injection

Guide for creating dependency injection with Feature per Module pattern.

## When to use this skill

- Create a Feature struct for a module
- Expose a public entry point for the feature
- Wire up dependencies with stored properties for stateful objects

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## File structure

```
Libraries/Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift              # Public entry point (struct implementing Feature protocol)
│   ├── Navigation/
│   │   ├── {Feature}Navigation.swift       # Navigation destinations
│   │   └── {Feature}DeepLinkHandler.swift  # Deep link handler (feature-level)
│   ├── Domain/
│   ├── Data/
│   └── Presentation/
│       ├── {Name}List/
│       │   ├── Navigator/                   # Screen-level navigators
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

**Notes:**
- **DeepLinkHandler** stays at feature level (`Sources/Navigation/`) - handles deep links for the whole feature
- **Navigators** are inside screen folders (`Presentation/{Screen}/Navigator/`) - each screen has its own navigator
- Feature struct contains all dependency wiring (no separate Container)
- Feature creates **Navigators** and injects them into ViewModels
- Views receive **only ViewModel** via init
- Navigation is handled by App using `NavigationPath`

---

## Feature Protocol (Core Module)

```swift
// Libraries/Core/Sources/Feature/Feature.swift
import SwiftUI

@MainActor
public protocol Feature {
    func registerDeepLinks()
    func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView
}
```

```swift
// Libraries/Core/Sources/Feature/View+FeatureNavigation.swift
import SwiftUI

public extension View {
    @MainActor
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

## Public Entry Point (Feature Struct)

```swift
// Sources/{Feature}Feature.swift
import {AppName}Common
import {AppName}Core
import {AppName}Networking
import SwiftUI

public struct {Feature}Feature: Feature {
    // MARK: - Dependencies

    private let httpClient: any HTTPClientContract
    private let memoryDataSource = {Name}MemoryDataSource()

    private var repository: any {Name}RepositoryContract {
        {Name}Repository(
            remoteDataSource: {Name}RemoteDataSource(httpClient: httpClient),
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Init

    public init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(baseURL: AppEnvironment.current.{api}.baseURL)
    }

    // MARK: - Feature Protocol

    @MainActor
    public func registerDeepLinks() {
        {Feature}DeepLinkHandler.register()
    }

    @MainActor
    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: {Feature}Navigation.self) { navigation in
                self.view(for: navigation, router: router)
            }
        )
    }

    // MARK: - Views

    @MainActor
    @ViewBuilder
    private func view(for navigation: {Feature}Navigation, router: any RouterContract) -> some View {
        switch navigation {
        case .list:
            {Name}ListView(viewModel: makeListViewModel(router: router))
        case .detail(let identifier):
            {Name}DetailView(viewModel: makeDetailViewModel(identifier: identifier, router: router))
        }
    }

    // MARK: - Factories

    func makeListViewModel(router: any RouterContract) -> {Name}ListViewModel {
        {Name}ListViewModel(
            get{Name}sUseCase: Get{Name}sUseCase(repository: repository),
            navigator: {Name}ListNavigator(router: router)
        )
    }

    func makeDetailViewModel(identifier: Int, router: any RouterContract) -> {Name}DetailViewModel {
        {Name}DetailViewModel(
            identifier: identifier,
            get{Name}UseCase: Get{Name}UseCase(repository: repository),
            navigator: {Name}DetailNavigator(router: router)
        )
    }
}
```

**Rules:**
- **public struct** implementing `Feature` protocol
- **private let httpClient** - Injected via init for testability
- **private let memoryDataSource** - Stored property (source of truth for caching)
- **private var repository** - Computed property (creates repository using shared memoryDataSource)
- **registerDeepLinks()** - Public method to register deep links (called from App.init)
- **applyNavigationDestination()** - Public method to register navigation destinations
- **view(for:router:)** - Private method, builds view for each navigation destination
- **Factory methods** - Internal for testability via `@testable`

---

## Simple Feature (No Data Layer)

```swift
// Sources/HomeFeature.swift
import {AppName}Core
import SwiftUI

public struct HomeFeature: Feature {
    public init() {}

    // MARK: - Feature Protocol

    @MainActor
    public func registerDeepLinks() {
        // Home has no deep links
    }

    @MainActor
    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(view)
    }

    // MARK: - Factory

    @MainActor
    public func makeHomeView(router: any RouterContract) -> some View {
        HomeView(viewModel: HomeViewModel(navigator: HomeNavigator(router: router)))
    }
}
```

---

## Navigator Pattern

Feature is responsible for creating Navigators:

```swift
func makeListViewModel(router: any RouterContract) -> {Name}ListViewModel {
    {Name}ListViewModel(
        get{Name}sUseCase: Get{Name}sUseCase(repository: repository),
        navigator: {Name}ListNavigator(router: router)  // Feature creates Navigator
    )
}
```

**Why Navigator in Feature?**
1. Feature owns the dependency graph
2. Navigator is a dependency of ViewModel
3. Feature knows which Navigator each ViewModel needs
4. ViewModel remains decoupled from routing implementation

---

## Dependency Patterns

| Type | Pattern | Reason |
|------|---------|--------|
| HTTPClient | Optional init parameter | Injectable for tests |
| MemoryDataSource | Instance property (`let`) | Maintains cache state |
| Repository | Computed property (`var`) | Uses shared memoryDataSource |
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
| Feature.registerDeepLinks() | **public** | Called from App.init |
| Feature.applyNavigationDestination() | **public** | Called via withNavigationDestinations |
| {Feature}Navigation | internal | Not exposed to App layer |
| {Feature}DeepLinkHandler | internal | Accessed via Feature.registerDeepLinks() |
| NavigatorContract | internal | Internal to feature |
| Navigator | internal | Internal implementation |
| Views | internal | Internal UI |
| Factory methods | internal | Accessible via @testable for tests |

---

## App Integration

### ChallengeApp (Centralized Features)

```swift
// App/Sources/ChallengeApp.swift
import {AppName}Character
import {AppName}Core
import {AppName}Home
import SwiftUI

@main
struct ChallengeApp: App {
    static let features: [any Feature] = [
        CharacterFeature(),
        HomeFeature()
    ]

    init() {
        Self.features.forEach { $0.registerDeepLinks() }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(features: Self.features)
        }
    }
}
```

### ContentView (Using Features)

```swift
// App/Sources/ContentView.swift
import {AppName}Character
import {AppName}Core
import {AppName}Home
import SwiftUI

struct ContentView: View {
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
    ContentView(features: [CharacterFeature(), HomeFeature()])
}
```

---

## Testing Features

Features must be tested to verify correct dependency wiring.

### File Structure

```
Libraries/Features/{Feature}/
└── Tests/
    └── Feature/
        └── {Feature}FeatureTests.swift
```

### What to Test

| Test | Purpose |
|------|---------|
| Factory returns instance | Verify wiring doesn't crash |
| Shared repository | Verify memoryDataSource is reused across ViewModels |
| Injected dependencies | Verify mock is used when injected |

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

- [ ] Create internal `Navigation/{Feature}Navigation.swift` conforming to `Navigation` protocol
- [ ] Create internal `{Feature}DeepLinkHandler.swift` in `Sources/Navigation/` with `register()` method
- [ ] Create `{Feature}Feature.swift` as struct implementing `Feature` protocol
- [ ] Feature has optional `httpClient` in init for testability
- [ ] Feature has stored `memoryDataSource` property (source of truth)
- [ ] Feature has computed `repository` property
- [ ] Create Navigator for each screen in `Presentation/{Screen}/Navigator/`
- [ ] Feature creates Navigator and injects into ViewModel
- [ ] Views only receive ViewModel
- [ ] Use factory methods for ViewModels (internal visibility for tests)
- [ ] Add feature to `ChallengeApp.features` array
- [ ] `ChallengeApp.init` iterates features to register deep links
- [ ] `ContentView` receives features and uses `.withNavigationDestinations(features:router:)`
- [ ] **Create feature tests verifying factory methods and shared repository**
