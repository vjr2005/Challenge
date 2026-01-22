---
name: dependency-injection
description: Creates Containers for dependency injection. Use when creating feature containers, exposing public entry points, or wiring up dependencies.
---

# Skill: Dependency Injection

Guide for creating dependency injection with Container per Feature pattern.

## When to use this skill

- Create a Container for a feature
- Expose a public entry point for the feature
- Wire up dependencies with lazy properties for stateful objects

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## File structure

```
Libraries/Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift              # Public entry point (enum with view builder)
│   ├── {Feature}Navigation.swift           # Public navigation destinations
│   ├── Navigation/
│   │   └── {Feature}DeepLinkHandler.swift  # Deep link handler (feature-level)
│   ├── Container/
│   │   └── {Feature}Container.swift        # Internal container (creates Navigators)
│   ├── Domain/
│   ├── Data/
│   └── Presentation/
│       ├── {Name}List/
│       │   ├── Navigation/                  # Screen-level navigators
│       │   │   ├── {Name}ListNavigatorContract.swift
│       │   │   └── {Name}ListNavigator.swift
│       │   ├── Views/
│       │   └── ViewModels/
│       └── {Name}Detail/
│           ├── Navigation/
│           │   ├── {Name}DetailNavigatorContract.swift
│           │   └── {Name}DetailNavigator.swift
│           ├── Views/
│           └── ViewModels/
```

**Notes:**
- **DeepLinkHandler** stays at feature level (`Sources/Navigation/`) - handles deep links for the whole feature
- **Navigators** are inside screen folders (`Presentation/{Screen}/Navigation/`) - each screen has its own navigator
- Container is at the root of Sources/, NOT inside Presentation/
- Container is accessed via static property in `{Feature}Feature` enum
- Container creates **Navigators** and injects them into ViewModels
- Views receive **only ViewModel** via init
- Navigation is handled by App using `NavigationPath`

---

## Navigation Destinations

```swift
// Sources/{Feature}Navigation.swift
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

## Public Entry Point

```swift
// Sources/{Feature}Feature.swift
import {AppName}Core
import SwiftUI

public enum {Feature}Feature {
    private static let container = {Feature}Container()

    // MARK: - Deep Links

    /// Registers deep link handlers for this feature.
    /// Call from `App.init()` to enable deep link navigation.
    @MainActor
    public static func registerDeepLinks() {
        {Feature}DeepLinkHandler.register()
    }

    // MARK: - Views (Internal)

    @ViewBuilder
    static func view(for navigation: {Feature}Navigation, router: RouterContract) -> some View {
        switch navigation {
        case .list:
            {Name}ListView(viewModel: container.makeListViewModel(router: router))
        case .detail(let identifier):
            {Name}DetailView(viewModel: container.makeDetailViewModel(identifier: identifier, router: router))
        }
    }
}

// MARK: - Navigation Destination

public extension View {
    /// Registers navigation destinations for this feature.
    func {feature}NavigationDestination(router: RouterContract) -> some View {
        navigationDestination(for: {Feature}Navigation.self) { navigation in
            {Feature}Feature.view(for: navigation, router: router)
        }
    }
}
```

**Rules:**
- **public enum** - Prevents instantiation, only static access
- **private static let container** - Shared container (lazy repository is source of truth)
- **registerDeepLinks()** - Public method to register deep links (called from App.init)
- **view(for:router:)** - Internal method, builds view for each navigation destination
- **{feature}NavigationDestination(router:)** - Public View extension for App to register navigation
- **{Feature}Navigation** - Internal enum, not exposed to App layer

---

## Internal Container

```swift
// Sources/Container/{Feature}Container.swift
import {AppName}Common
import {AppName}Core
import {AppName}Networking
import Foundation

final class {Feature}Container {
    // MARK: - Infrastructure

    private let httpClient: any HTTPClientContract

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(baseURL: AppEnvironment.current.{api}.baseURL)
    }

    // MARK: - Shared (lazy) - Source of Truth

    private let memoryDataSource = {Name}MemoryDataSource()

    private lazy var repository: any {Name}RepositoryContract = {Name}Repository(
        remoteDataSource: {Name}RemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    // MARK: - Factories

    func makeListViewModel(router: RouterContract) -> {Name}ListViewModel {
        {Name}ListViewModel(
            get{Name}sUseCase: makeGet{Name}sUseCase(),
            navigator: {Name}ListNavigator(router: router)
        )
    }

    func makeDetailViewModel(identifier: Int, router: RouterContract) -> {Name}DetailViewModel {
        {Name}DetailViewModel(
            identifier: identifier,
            get{Name}UseCase: makeGet{Name}UseCase(),
            navigator: {Name}DetailNavigator(router: router)
        )
    }

    private func makeGet{Name}sUseCase() -> some Get{Name}sUseCaseContract {
        Get{Name}sUseCase(repository: repository)
    }

    private func makeGet{Name}UseCase() -> some Get{Name}UseCaseContract {
        Get{Name}UseCase(repository: repository)
    }
}
```

**Rules:**
- **final class** - Allows instance properties and lazy initialization
- **httpClient via init** - Optional injection for testability
- **lazy var repository** - Source of truth, initialized on first access
- **Navigator creation** - Container creates Navigator with router and injects into ViewModel
- **Private UseCase factories** - Only ViewModels are created externally
- **Internal visibility** - Container is not public

---

## Navigator Pattern

Container is responsible for creating Navigators:

```swift
func makeListViewModel(router: RouterContract) -> {Name}ListViewModel {
    {Name}ListViewModel(
        get{Name}sUseCase: makeGet{Name}sUseCase(),
        navigator: {Name}ListNavigator(router: router)  // Container creates Navigator
    )
}
```

**Why Navigator in Container?**
1. Container owns the dependency graph
2. Navigator is a dependency of ViewModel
3. Container knows which Navigator each ViewModel needs
4. ViewModel remains decoupled from routing implementation

---

## Lazy vs Factory

| Type | Pattern | Reason |
|------|---------|--------|
| HTTPClient | Optional init parameter | Injectable for tests |
| MemoryDataSource | Instance property | Maintains cache state |
| Repository | `lazy var` | Source of truth |
| Navigator | Factory method (inline) | New instance per ViewModel |
| ViewModel | Factory method | New instance per navigation |
| UseCase | Factory method | Stateless, can be new |

---

## Visibility Summary

| Component | Visibility | Reason |
|-----------|------------|--------|
| Contract (Protocol) | **public** | API for consumers, enables DI |
| Implementation (Class) | **public** / **open** | Direct instantiation allowed |
| {Feature}Feature | **public** | Entry point enum |
| {Feature}Feature.registerDeepLinks() | **public** | Called from App.init |
| View.{feature}NavigationDestination() | **public** | Called from ContentView |
| {Feature}Navigation | internal | Not exposed to App layer |
| {Feature}DeepLinkHandler | internal | Accessed via Feature.registerDeepLinks() |
| {Feature}Container | internal | Internal wiring |
| NavigatorContract | internal | Internal to feature |
| Navigator | internal | Internal implementation |
| Views | internal | Internal UI |

---

## Testing Containers

Containers must be tested to verify correct dependency wiring.

### File Structure

```
Libraries/Features/{Feature}/
└── Tests/
    └── Container/
        └── {Feature}ContainerTests.swift
```

### What to Test

| Test | Purpose |
|------|---------|
| Factory returns instance | Verify wiring doesn't crash |
| Shared repository | Verify lazy var is reused across ViewModels |
| Injected dependencies | Verify mock is used when injected |

For complete test examples, see [examples.md](examples.md).

---

## Example: Home Feature (External Navigation)

For features that navigate **externally** to other features:

```swift
// Sources/Container/HomeContainer.swift
import {AppName}Core

final class HomeContainer {
    func makeHomeViewModel(router: RouterContract) -> HomeViewModel {
        HomeViewModel(navigator: HomeNavigator(router: router))
    }
}
```

```swift
// Sources/Presentation/Home/Navigation/HomeNavigatorContract.swift
protocol HomeNavigatorContract {
    func navigateToCharacters()
}
```

```swift
// Sources/Presentation/Home/Navigation/HomeNavigator.swift
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

- [ ] Create internal `{Feature}Navigation.swift` conforming to `Navigation` protocol
- [ ] Create internal `{Feature}DeepLinkHandler.swift` in `Sources/Navigation/` with `register()` method
- [ ] Create `{Feature}Feature.swift` with `registerDeepLinks()` and View extension `{feature}NavigationDestination(router:)`
- [ ] Create internal Container as `final class` with optional `httpClient` in init
- [ ] Use `lazy var` for repository (source of truth)
- [ ] Create Navigator for each screen in `Presentation/{Screen}/Navigation/`
- [ ] Container creates Navigator and injects into ViewModel
- [ ] Views only receive ViewModel
- [ ] Use factory methods for ViewModels
- [ ] `ContentView` uses `.{feature}NavigationDestination(router:)` extension
- [ ] `ChallengeApp` calls `{Feature}Feature.registerDeepLinks()` in init
- [ ] **Create container tests verifying factory methods and shared repository**
