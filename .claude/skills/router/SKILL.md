---
name: router
description: Creates Router for navigation. Use when setting up navigation, adding navigation to ViewModels, or testing navigation behavior.
---

# Skill: Router

Guide for implementing navigation using NavigationCoordinator with SwiftUI NavigationStack, Navigator pattern for decoupling, and Outgoing/Incoming Navigation for cross-feature communication.

## When to use this skill

- Set up navigation in the App
- Add navigation to ViewModels via Navigator pattern
- Implement deep link handlers for features
- Connect features via Outgoing/Incoming Navigation
- Test navigation behavior

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          RootContainerView                              │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  @State private var coordinator = NavigationCoordinator(        │    │
│  │      redirector: AppNavigationRedirect()                        │    │
│  │  )                                                              │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                │                                        │
│  NavigationStack(path: $coordinator.path) {                             │
│      Features receive coordinator (NavigatorContract)                   │
│  }                                                                      │
└─────────────────────────────────────────────────────────────────────────┘

Navigation Flow:
1. HomeNavigator.navigateToCharacters()
2. coordinator.navigate(to: HomeOutgoingNavigation.characters)
3. AppNavigationRedirect.redirect() → CharacterIncomingNavigation.list
4. NavigationStack shows CharacterListView
```

---

## Navigation Types

| Type | Description | Implementation |
|------|-------------|----------------|
| **Incoming** | Destinations a feature can handle | `{Feature}IncomingNavigation` enum |
| **Outgoing** | Destinations a feature wants to navigate to | `{Feature}OutgoingNavigation` enum |
| **Redirect** | Connects Outgoing → Incoming | `AppNavigationRedirect` in App layer |

**Why?** Features remain decoupled. Feature A doesn't import Feature B. The App layer connects them via redirects.

---

## Core Module Components

### NavigatorContract (Protocol)

```swift
// Libraries/Core/Sources/Navigation/NavigatorContract.swift
import Foundation

public protocol NavigatorContract {
    func navigate(to destination: any Navigation)
    func goBack()
}
```

### Navigation (Protocol)

```swift
// Libraries/Core/Sources/Navigation/Navigation.swift
public protocol Navigation: Hashable, Sendable {}
```

### NavigationCoordinator (Implementation)

```swift
// Libraries/Core/Sources/Navigation/NavigationCoordinator.swift
import Foundation
import SwiftUI

@Observable
public final class NavigationCoordinator: NavigatorContract {
    public var path = NavigationPath()

    private let redirector: (any NavigationRedirectContract)?

    public init(redirector: (any NavigationRedirectContract)? = nil) {
        self.redirector = redirector
    }

    public func navigate(to destination: any Navigation) {
        let resolved = redirector?.redirect(destination) ?? destination
        path.append(resolved)
    }

    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }
}
```

### NavigationRedirectContract (Protocol)

```swift
// Libraries/Core/Sources/Navigation/NavigationRedirectContract.swift
import Foundation

public protocol NavigationRedirectContract: Sendable {
    func redirect(_ navigation: any Navigation) -> (any Navigation)?
}
```

### Feature Protocol

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
- `resolve()` handles navigation destinations (returns `nil` if not handled)

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

### NavigatorMock (for testing)

```swift
// Libraries/Core/Mocks/NavigatorMock.swift
import ChallengeCore
import Foundation

public final class NavigatorMock: NavigatorContract {
    public private(set) var navigatedDestinations: [any Navigation] = []
    public private(set) var goBackCallCount = 0

    public init() {}

    public func navigate(to destination: any Navigation) {
        navigatedDestinations.append(destination)
    }

    public func goBack() {
        goBackCallCount += 1
    }
}
```

---

## Feature Navigation

Each feature defines Incoming and optionally Outgoing navigation:

### Incoming Navigation (Destinations the feature handles)

```swift
// Features/{Feature}/Sources/Presentation/Navigation/{Feature}IncomingNavigation.swift
import ChallengeCore

public enum {Feature}IncomingNavigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

### Outgoing Navigation (Destinations to other features)

```swift
// Features/{Feature}/Sources/Presentation/Navigation/{Feature}OutgoingNavigation.swift
import ChallengeCore

public enum {Feature}OutgoingNavigation: Navigation {
    case characters  // Navigates to Character feature
    case settings    // Navigates to Settings feature
}
```

**Note:** Outgoing navigations are `public` so AppNavigationRedirect can access them.

### DeepLinkHandler

```swift
// Features/{Feature}/Sources/Presentation/Navigation/{Feature}DeepLinkHandler.swift
import ChallengeCore
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandler {
    let scheme = "challenge"
    let host = "{feature}"  // e.g., "character"

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

**URL Format:** `challenge://{feature}/{path}?param=value`

Examples:
- `challenge://character/list`
- `challenge://character/detail?id=42`

---

## App Layer: Connecting Features

### AppNavigationRedirect

```swift
// App/Sources/Navigation/AppNavigationRedirect.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeHome

struct AppNavigationRedirect: NavigationRedirectContract {
    func redirect(_ navigation: any Navigation) -> (any Navigation)? {
        switch navigation {
        case let outgoing as HomeOutgoingNavigation:
            return redirect(outgoing)
        default:
            return nil
        }
    }

    // MARK: - Private

    private func redirect(_ navigation: HomeOutgoingNavigation) -> any Navigation {
        switch navigation {
        case .characters:
            return CharacterIncomingNavigation.list
        }
    }
}
```

**Rules:**
- Centralized place to connect features
- Maps Outgoing → Incoming navigation
- Only place that imports multiple features

### RootContainerView

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
- Uses `AnyNavigation` wrapper for type-erased navigation in `NavigationPath`
- `appContainer.resolve()` iterates through features to find the handler
- Located in `AppKit` module (not `App`) for testability

### AppContainer (Navigation Resolution)

```swift
// AppKit/Sources/AppContainer.swift

/// Resolves any navigation to a view by iterating through features.
/// Falls back to NotFoundView if no feature can handle the navigation.
public func resolve(
    _ navigation: any Navigation,
    navigator: any NavigatorContract
) -> AnyView {
    for feature in features {
        if let view = feature.resolve(navigation, navigator: navigator) {
            return view
        }
    }
    // Fallback to NotFoundView
    return systemFeature.makeMainView(navigator: navigator)
}

/// Handles deep links by resolving URLs to navigation.
public func handle(url: URL, navigator: any NavigatorContract) {
    for feature in features {
        if let navigation = feature.deepLinkHandler?.resolve(url) {
            navigator.navigate(to: navigation)
            return
        }
    }
}
```

---

## Navigator Pattern

ViewModels use **Navigators** instead of NavigatorContract directly. This:
1. Decouples ViewModels from navigation implementation details
2. Makes testing easier with focused mocks
3. Provides semantic navigation methods

### Navigator Contract

```swift
// Features/{Feature}/Sources/Presentation/{Screen}/Navigator/{Screen}NavigatorContract.swift
protocol {Screen}NavigatorContract {
    func navigateToDetail(id: Int)  // Internal navigation
    func goBack()
}
```

### Navigator Implementation (Internal Navigation)

```swift
// Features/{Feature}/Sources/Presentation/{Screen}/Navigator/{Screen}Navigator.swift
import ChallengeCore

struct {Screen}Navigator: {Screen}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToDetail(id: Int) {
        // Uses IncomingNavigation (same feature)
        navigator.navigate(to: {Feature}IncomingNavigation.detail(identifier: id))
    }

    func goBack() {
        navigator.goBack()
    }
}
```

### Navigator Implementation (External Navigation)

```swift
// Features/Home/Sources/Presentation/Home/Navigator/HomeNavigator.swift
import ChallengeCore

struct HomeNavigator: HomeNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToCharacters() {
        // Uses OutgoingNavigation (different feature)
        // AppNavigationRedirect will convert to CharacterIncomingNavigation.list
        navigator.navigate(to: HomeOutgoingNavigation.characters)
    }
}
```

**Key Difference:**
- **Internal:** Uses `{Feature}IncomingNavigation` directly
- **External:** Uses `{Feature}OutgoingNavigation` (redirected by App layer)

---

## Feature Implementation

### Feature Struct

```swift
// Features/{Feature}/Sources/{Feature}Feature.swift
import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct {Feature}Feature: Feature {
    private let container: {Feature}Container

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

---

## ViewModel with Navigator

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

    func didSelectItem(_ item: Item) {
        navigator.navigateToDetail(id: item.id)
    }

    func didTapOnBack() {
        navigator.goBack()
    }
}
```

---

## Testing Navigation

### Navigator Mock

```swift
// Features/{Feature}/Tests/Mocks/{Screen}NavigatorMock.swift
@testable import Challenge{Feature}

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

### Navigator Tests

```swift
// Features/{Feature}/Tests/Presentation/{Screen}/Navigator/{Screen}NavigatorTests.swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}NavigatorTests {
    @Test
    func navigateToDetailUsesCorrectNavigation() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = {Screen}Navigator(navigator: navigatorMock)

        // When
        sut.navigateToDetail(id: 42)

        // Then
        let destination = navigatorMock.navigatedDestinations.first as? {Feature}IncomingNavigation
        #expect(destination == .detail(identifier: 42))
    }
}
```

### AppNavigationRedirect Tests

```swift
// App/Tests/Navigation/AppNavigationRedirectTests.swift
import ChallengeCharacter
import ChallengeHome
import Testing

@testable import Challenge

struct AppNavigationRedirectTests {
    @Test
    func redirectHomeOutgoingCharactersToCharacterList() throws {
        // Given
        let sut = AppNavigationRedirect()

        // When
        let result = sut.redirect(HomeOutgoingNavigation.characters)

        // Then
        let characterNavigation = try #require(result as? CharacterIncomingNavigation)
        #expect(characterNavigation == .list)
    }

    @Test
    func redirectUnknownNavigationReturnsNil() {
        // Given
        let sut = AppNavigationRedirect()

        // When
        let result = sut.redirect(CharacterIncomingNavigation.list)

        // Then
        #expect(result == nil)
    }
}
```

### DeepLinkHandler Tests

```swift
import ChallengeCore
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Feature}DeepLinkHandlerTests {
    @Test
    func resolvesListURL() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/list"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? {Feature}IncomingNavigation == .list)
    }

    @Test
    func resolvesDetailURL() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/detail?id=42"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? {Feature}IncomingNavigation == .detail(identifier: 42))
    }
}
```

---

## File Structure

```
Libraries/Core/
├── Sources/
│   ├── Feature/
│   │   └── Feature.swift                    # Feature protocol
│   └── Navigation/
│       ├── NavigationCoordinator.swift      # @Observable, manages path + redirects
│       ├── NavigatorContract.swift          # Protocol for navigation
│       ├── NavigationRedirectContract.swift # Protocol for redirects
│       ├── Navigation.swift                 # Base protocol
│       ├── AnyNavigation.swift              # Type-erased wrapper for NavigationPath
│       └── DeepLinkHandler.swift            # Protocol for deep links
└── Mocks/
    └── NavigatorMock.swift

AppKit/Sources/                              # Note: AppKit, not App (for testability)
├── AppContainer.swift                       # resolve() and handle(url:)
└── Presentation/
    ├── Navigation/
    │   └── AppNavigationRedirect.swift      # Connects features via redirects
    └── Views/
        └── RootContainerView.swift          # Creates NavigationCoordinator

Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift
│   ├── {Feature}Container.swift
│   └── Presentation/
│       ├── Navigation/                      # Inside Presentation folder
│       │   ├── {Feature}IncomingNavigation.swift  # Destinations this feature handles
│       │   ├── {Feature}OutgoingNavigation.swift  # Destinations to other features (optional)
│       │   └── {Feature}DeepLinkHandler.swift
│       └── {Screen}/
│           └── Navigator/
│               ├── {Screen}NavigatorContract.swift
│               └── {Screen}Navigator.swift
└── Tests/
    └── Unit/
        └── Presentation/
            └── Navigation/
                ├── {Feature}DeepLinkHandlerTests.swift
                └── {Screen}NavigatorTests.swift
```

---

## Checklist

### Core Setup
- [ ] Core has `NavigatorContract` protocol
- [ ] Core has `NavigationRedirectContract` protocol
- [ ] Core has `NavigationCoordinator` (@Observable, manages path + redirects)
- [ ] Core has `Navigation` protocol
- [ ] Core has `AnyNavigation` type-erased wrapper
- [ ] Core has `DeepLinkHandler` protocol
- [ ] Core has `Feature` protocol with `makeMainView()` and `resolve()` methods
- [ ] Core has `NavigatorMock` for testing

### AppKit Configuration
- [ ] `Project.swift` has `CFBundleURLTypes` with URL scheme (e.g., `challenge`)
- [ ] `AppNavigationRedirect` in `AppKit/Sources/Presentation/Navigation/`
- [ ] `RootContainerView` in `AppKit/Sources/Presentation/Views/`
- [ ] `RootContainerView` uses `.navigationDestination(for: AnyNavigation.self)`
- [ ] `AppContainer.resolve()` iterates features and falls back to NotFoundView
- [ ] `AppContainer.handle(url:navigator:)` resolves deep links via feature handlers

### Feature Implementation
- [ ] Feature has `{Feature}IncomingNavigation` in `Presentation/Navigation/`
- [ ] Feature has `{Feature}OutgoingNavigation` for cross-feature navigation (if needed)
- [ ] Feature has `{Feature}DeepLinkHandler` returning `IncomingNavigation` (if deep links needed)
- [ ] Feature implements `makeMainView(navigator:)` returning default entry point
- [ ] Feature implements `resolve(_:navigator:)` returning view or nil
- [ ] Each screen has `NavigatorContract` and `Navigator`
- [ ] Navigator uses `IncomingNavigation` for internal, `OutgoingNavigation` for external
- [ ] Container factories receive `navigator: any NavigatorContract`
- [ ] ViewModel receives specific `NavigatorContract` (not generic)

### Testing
- [ ] Tests use `NavigatorMock` to verify navigation
- [ ] Navigator tests verify correct Navigation enum is used
- [ ] AppNavigationRedirect tests verify Outgoing → Incoming mapping
- [ ] DeepLinkHandler tests verify URL → IncomingNavigation resolution
