---
name: router
description: Creates Router for navigation. Use when setting up navigation, adding navigation to ViewModels, or testing navigation behavior.
---

# Skill: Router

Guide for implementing navigation using Router pattern with SwiftUI NavigationStack, Navigator pattern for decoupling, and Deep Links for cross-feature navigation.

## When to use this skill

- Set up navigation in the App
- Add navigation to ViewModels via Navigator pattern
- Implement deep link handlers for features
- Test navigation behavior

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         App                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  let features: [any Feature] = [...]                │    │
│  │  init() { features.forEach { $0.registerDeepLinks() } }  │
│  └─────────────────────────────────────────────────────┘    │
│                            │                                 │
│                            ▼ passes features                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  ContentView(features: features)                    │    │
│  │  @State private var router = Router()               │    │
│  │  .withNavigationDestinations(features:, router:)    │    │
│  └─────────────────────────────────────────────────────┘    │
│                            │                                 │
│                            ▼ Feature creates Navigator       │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  feature.makeViewModel(router: router)              │    │
│  │  → Navigator = Navigator(router: router)            │    │
│  │  → ViewModel(navigator: navigator)                  │    │
│  └─────────────────────────────────────────────────────┘    │
│                            │                                 │
│                            ▼ ViewModel uses Navigator        │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  navigator.navigateToDetail(id:)  // INTERNAL       │    │
│  │  navigator.navigateToExternal()   // EXTERNAL (URL) │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## Navigation Types

| Type | Description | Implementation |
|------|-------------|----------------|
| **INTERNAL** | Same feature navigation | Use `Navigation` enum directly |
| **EXTERNAL** | Cross-feature navigation | Use URL deep links |

**Why?** External navigation via URLs allows features to remain decoupled. Feature A doesn't need to import Feature B.

---

## Core Module Components

### Feature Protocol

```swift
// Libraries/Core/Sources/Feature/Feature.swift
import SwiftUI

@MainActor
public protocol Feature {
    func registerDeepLinks()
    func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView
}
```

### View Extension for Features

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

### RouterContract (Protocol)

```swift
// Libraries/Core/Sources/Navigation/RouterContract.swift
import Foundation

public protocol RouterContract {
    func navigate(to destination: any Navigation)
    func navigate(to url: URL?)
    func goBack()
}
```

### Navigation (Protocol)

```swift
// Libraries/Core/Sources/Navigation/Navigation.swift
public protocol Navigation: Hashable, Sendable {}
```

### Router (Implementation)

```swift
// Libraries/Core/Sources/Navigation/Router.swift
import Foundation
import SwiftUI

@Observable
public final class Router: RouterContract {
    public var path = NavigationPath()

    public init() {}

    public func navigate(to destination: any Navigation) {
        path.append(destination)
    }

    public func navigate(to url: URL?) {
        guard let url,
              let destination = DeepLinkRegistry.shared.resolve(url) else {
            return
        }
        path.append(destination)
    }

    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }
}
```

### DeepLinkHandler (Protocol)

```swift
// Libraries/Core/Sources/Navigation/DeepLinkHandler.swift
import Foundation

public protocol DeepLinkHandler: Sendable {
    var scheme: String { get }
    var host: String { get }
    func resolve(_ url: URL) -> (any Navigation)?
}
```

### DeepLinkRegistry (Singleton)

```swift
// Libraries/Core/Sources/Navigation/DeepLinkRegistry.swift
import Foundation

public final class DeepLinkRegistry: @unchecked Sendable {
    public static let shared = DeepLinkRegistry()

    private var handlers: [String: any DeepLinkHandler] = [:]
    private let lock = NSLock()

    public init() {}

    public func register(_ handler: any DeepLinkHandler) {
        let key = "\(handler.scheme)://\(handler.host)"
        lock.lock()
        handlers[key] = handler
        lock.unlock()
    }

    public func resolve(_ url: URL) -> (any Navigation)? {
        guard let scheme = url.scheme, let host = url.host else {
            return nil
        }
        let key = "\(scheme)://\(host)"
        lock.lock()
        let handler = handlers[key]
        lock.unlock()
        return handler?.resolve(url)
    }
}
```

### URL+QueryParameter (Extension)

```swift
// Libraries/Core/Sources/Extensions/URL+QueryParameter.swift
import Foundation

public extension URL {
    func queryParameter(_ name: String) -> String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == name }?
            .value
    }
}
```

### RouterMock (for testing)

```swift
// Libraries/Core/Mocks/RouterMock.swift
import {AppName}Core
import Foundation

public final class RouterMock: RouterContract {
    public private(set) var navigatedDestinations: [any Navigation] = []
    public private(set) var navigatedURLs: [URL] = []
    public private(set) var goBackCallCount = 0

    public init() {}

    public func navigate(to destination: any Navigation) {
        navigatedDestinations.append(destination)
    }

    public func navigate(to url: URL?) {
        guard let url else {
            return
        }
        navigatedURLs.append(url)
    }

    public func goBack() {
        goBackCallCount += 1
    }
}
```

---

## Feature Navigation

Each feature defines its navigation destinations and deep link handler:

### Navigation Enum (Internal)

```swift
// Features/{Feature}/Sources/Navigation/{Feature}Navigation.swift
import {AppName}Core

enum {Feature}Navigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

**Note:** Navigation enum is `internal` - not exposed to App layer. App uses `withNavigationDestinations(features:router:)` instead.

### DeepLinkHandler (Internal)

```swift
// Features/{Feature}/Sources/Navigation/{Feature}DeepLinkHandler.swift
import {AppName}Core
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandler {
    let scheme = "challenge"
    let host = "{feature}"  // e.g., "character"

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

**URL Format:** `challenge://{feature}/{path}?param=value`

Examples:
- `challenge://character/list`
- `challenge://character/detail?id=42`

---

## Navigator Pattern

ViewModels use **Navigators** instead of Router directly. This:
1. Decouples ViewModels from navigation implementation details
2. Makes testing easier with focused mocks
3. Separates internal vs external navigation concerns

### Navigator Contract

```swift
// Features/{Feature}/Sources/Presentation/{Screen}/Navigator/{Screen}NavigatorContract.swift
protocol {Screen}NavigatorContract {
    func navigateToDetail(id: Int)  // INTERNAL navigation
    func goBack()
}
```

### Navigator Implementation

```swift
// Features/{Feature}/Sources/Presentation/{Screen}/Navigator/{Screen}Navigator.swift
import {AppName}Core

struct {Screen}Navigator: {Screen}NavigatorContract {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func navigateToDetail(id: Int) {
        // INTERNAL: uses Navigation directly
        router.navigate(to: {Feature}Navigation.detail(identifier: id))
    }

    func goBack() {
        router.goBack()
    }
}
```

### Navigator for External Navigation (Cross-Feature)

```swift
// Features/Home/Sources/Presentation/Home/Navigator/HomeNavigatorContract.swift
protocol HomeNavigatorContract {
    func navigateToCharacters()  // EXTERNAL navigation
}

// Features/Home/Sources/Presentation/Home/Navigator/HomeNavigator.swift
import {AppName}Core
import Foundation

struct HomeNavigator: HomeNavigatorContract {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func navigateToCharacters() {
        // EXTERNAL: URL hardcoded (no import of Character feature)
        router.navigate(to: URL(string: "challenge://character/list"))
    }
}
```

**Key Difference:**
- **INTERNAL:** `router.navigate(to: {Feature}Navigation.detail(...))`
- **EXTERNAL:** `router.navigate(to: URL(string: "challenge://..."))`

---

## App Setup

### ChallengeApp (Centralized Features)

```swift
// App/Sources/ChallengeApp.swift
import {AppName}Character
import {AppName}Core
import {AppName}Home
import SwiftUI

@main
struct ChallengeApp: App {
    let features: [any Feature] = [
        CharacterFeature(),
        HomeFeature()
    ]

    init() {
        features.forEach { $0.registerDeepLinks() }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(features: features)
        }
    }
}
```

### ContentView (Navigation Stack with Features)

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

**Rules:**
- Define features in `ChallengeApp` as instance property
- Register deep links in `ChallengeApp.init()` by iterating features
- Pass features to ContentView
- Create Router with `@State` in ContentView
- Bind path with `$router.path`
- Use `.withNavigationDestinations(features:router:)` to register all navigation destinations
- Use `.onOpenURL` to handle external URLs (from Safari, other apps, push notifications)

---

## ViewModel with Navigator

ViewModels receive **NavigatorContract**, not RouterContract:

```swift
// Features/{Feature}/Sources/Presentation/ViewModels/{Name}ViewModel.swift
import Foundation

@Observable
final class {Name}ViewModel {
    private(set) var state: {Name}ViewState = .idle

    private let get{Name}UseCase: Get{Name}UseCaseContract
    private let navigator: {Name}NavigatorContract

    init(get{Name}UseCase: Get{Name}UseCaseContract, navigator: {Name}NavigatorContract) {
        self.get{Name}UseCase = get{Name}UseCase
        self.navigator = navigator
    }

    func load() async {
        // ...
    }

    func didSelectItem(_ item: Item) {
        navigator.navigateToDetail(id: item.id)
    }

    func didTapOnBack() {
        navigator.goBack()
    }
}
```

**Rules:**
- Inject **NavigatorContract** (not RouterContract)
- Use semantic method names: `didTapOn...`, `didSelect...`
- Navigator handles the routing details

---

## Feature Wiring

Feature creates Navigator and injects into ViewModel:

```swift
// Features/{Feature}/Sources/{Feature}Feature.swift
import {AppName}Core
import SwiftUI

public struct {Feature}Feature: Feature {
    // ...

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

---

## Testing Navigation

### Navigator Mock

```swift
// Features/{Feature}/Tests/Mocks/{Screen}NavigatorMock.swift
@testable import {AppName}{Feature}

final class {Screen}NavigatorMock: {Screen}NavigatorContract {
    private(set) var navigateToDetailIds: [Int] = []
    private(set) var goBackCallCount = 0

    func navigateToDetail(id: Int) {
        navigateToDetailIds.append(id)
    }

    func goBack() {
        goBackCallCount += 1
    }
}
```

### ViewModel Tests

```swift
import Testing

@testable import {AppName}{Feature}

struct {Name}ViewModelTests {
    @Test
    func didSelectItemNavigatesToDetail() {
        // Given
        let navigatorMock = {Name}NavigatorMock()
        let sut = {Name}ViewModel(
            get{Name}UseCase: Get{Name}UseCaseMock(),
            navigator: navigatorMock
        )

        // When
        sut.didSelectItem(Item(id: 42))

        // Then
        #expect(navigatorMock.navigateToDetailIds == [42])
    }

    @Test
    func didTapOnBackCallsNavigator() {
        // Given
        let navigatorMock = {Name}NavigatorMock()
        let sut = {Name}ViewModel(
            get{Name}UseCase: Get{Name}UseCaseMock(),
            navigator: navigatorMock
        )

        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}
```

### Navigator Tests

```swift
// Features/{Feature}/Tests/Presentation/{Screen}/Navigator/{Screen}NavigatorTests.swift
import {AppName}CoreMocks
import Testing

@testable import {AppName}{Feature}

struct {Screen}NavigatorTests {
    @Test
    func navigateToDetailUsesCorrectNavigation() {
        // Given
        let routerMock = RouterMock()
        let sut = {Screen}Navigator(router: routerMock)

        // When
        sut.navigateToDetail(id: 42)

        // Then
        let destination = routerMock.navigatedDestinations.first as? {Feature}Navigation
        #expect(destination == .detail(identifier: 42))
    }
}
```

### DeepLinkHandler Tests

```swift
import {AppName}Core
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Feature}DeepLinkHandlerTests {
    @Test
    func resolvesListURL() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/list"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? {Feature}Navigation == .list)
    }

    @Test
    func resolvesDetailURL() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/detail?id=42"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? {Feature}Navigation == .detail(identifier: 42))
    }

    @Test
    func returnsNilForUnknownPath() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/unknown"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value == nil)
    }
}
```

---

## File Structure

```
Libraries/Core/
├── Sources/
│   ├── Feature/
│   │   ├── Feature.swift                    # Feature protocol
│   │   └── View+FeatureNavigation.swift     # withNavigationDestinations extension
│   └── Navigation/
│       ├── Router.swift
│       ├── RouterContract.swift
│       ├── Navigation.swift
│       ├── DeepLinkHandler.swift
│       └── DeepLinkRegistry.swift
└── Mocks/
    └── RouterMock.swift

Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift               # Feature struct implementing Feature protocol
│   ├── Navigation/
│   │   ├── {Feature}Navigation.swift        # Navigation destinations
│   │   └── {Feature}DeepLinkHandler.swift   # Feature-level (handles deep links)
│   ├── Domain/
│   ├── Data/
│   └── Presentation/
│       ├── {Screen}List/
│       │   ├── Navigator/                    # Screen-level navigators
│       │   │   ├── {Screen}ListNavigatorContract.swift
│       │   │   └── {Screen}ListNavigator.swift
│       │   ├── Views/
│       │   └── ViewModels/
│       └── {Screen}Detail/
│           ├── Navigator/
│           │   ├── {Screen}DetailNavigatorContract.swift
│           │   └── {Screen}DetailNavigator.swift
│           ├── Views/
│           └── ViewModels/
└── Tests/
    ├── Mocks/
    │   └── {Screen}NavigatorMock.swift
    ├── Navigation/
    │   └── {Feature}DeepLinkHandlerTests.swift
    └── Presentation/
        ├── {Screen}List/
        │   └── Navigator/
        │       └── {Screen}ListNavigatorTests.swift
        └── {Screen}Detail/
            └── Navigator/
                └── {Screen}DetailNavigatorTests.swift
```

**Notes:**
- **Feature protocol** is in Core module (`Sources/Feature/`)
- **DeepLinkHandler** stays at feature level (`Sources/Navigation/`) - handles external URLs for the whole feature
- **Navigators** are inside screen folders (`Presentation/{Screen}/Navigator/`) - each screen has its own navigator

---

## Checklist

### Core Setup
- [ ] Core has `Feature` protocol and `View+FeatureNavigation` extension
- [ ] Core has `RouterContract`, `Navigation`, `Router`, `RouterMock`
- [ ] Core has `DeepLinkHandler`, `DeepLinkRegistry`, `URL+QueryParameter`

### App Configuration
- [ ] `Project.swift` has `CFBundleURLTypes` with URL scheme (e.g., `challenge`)
- [ ] `ChallengeApp` has `let features: [any Feature]` property
- [ ] `ChallengeApp.init` iterates features to call `registerDeepLinks()`
- [ ] `ChallengeApp` passes features to `ContentView(features:)`
- [ ] `ContentView` creates `@State private var router = Router()`
- [ ] `ContentView` uses `NavigationStack(path: $router.path)`
- [ ] `ContentView` uses `.withNavigationDestinations(features:router:)`
- [ ] `ContentView` uses `.onOpenURL { url in router.navigate(to: url) }` for external URLs

### Feature Implementation
- [ ] Feature struct implements `Feature` protocol
- [ ] Feature has internal `{Feature}Navigation` conforming to `Navigation`
- [ ] Feature has `{Feature}DeepLinkHandler` in `Sources/Navigation/` with `register()` method
- [ ] Feature implements `registerDeepLinks()` method
- [ ] Feature implements `applyNavigationDestination()` method
- [ ] Each screen has `NavigatorContract` and `Navigator` in `Presentation/{Screen}/Navigator/`
- [ ] Feature creates Navigator and injects into ViewModel
- [ ] ViewModel injects `NavigatorContract` (not RouterContract)

### Testing
- [ ] Tests use `NavigatorMock` to verify navigation
- [ ] Tests for Navigator in `Tests/Presentation/{Screen}/Navigator/` verify Router calls
- [ ] Tests for DeepLinkHandler in `Tests/Navigation/` verify URL resolution
