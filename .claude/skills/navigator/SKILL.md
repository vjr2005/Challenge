---
name: navigator
description: Creates Navigator for navigation. Use when setting up navigation, adding navigation to ViewModels, or testing navigation behavior.
---

# Skill: Navigator

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
│  NavigationStack(path: $coordinator.path) { ... }                       │
│  .sheet(item: $coordinator.sheetNavigation) { modal in                  │
│      ModalContainerView(modal:appContainer:onDismiss:)                  │
│  }                                                                      │
│  .fullScreenCover(item: $coordinator.fullScreenCoverNavigation) { ... } │
└─────────────────────────────────────────────────────────────────────────┘

Push Navigation Flow:
1. HomeNavigator.navigateToCharacters()
2. coordinator.navigate(to: HomeOutgoingNavigation.characters)
3. AppNavigationRedirect.redirect() → CharacterIncomingNavigation.list
4. NavigationStack shows CharacterListView

Modal Navigation Flow:
1. Navigator.presentFilter()
2. coordinator.present(Navigation.filter, style: .sheet(detents: [.medium, .large]))
3. sheetNavigation is set → .sheet(item:) activates
4. ModalContainerView creates its own NavigationCoordinator + NavigationStack
5. Modal can push internally or present nested modals
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
    func navigate(to destination: any NavigationContract)
    func present(_ destination: any NavigationContract, style: ModalPresentationStyle)
    func dismiss()
    func goBack()
}
```

### NavigationContract (Protocol)

```swift
// Libraries/Core/Sources/Navigation/Navigation.swift
nonisolated public protocol NavigationContract: Hashable, Sendable {}
nonisolated public protocol IncomingNavigationContract: NavigationContract {}
nonisolated public protocol OutgoingNavigationContract: NavigationContract {}
```

### ModalPresentationStyle

```swift
// Libraries/Core/Sources/Navigation/ModalPresentationStyle.swift
import SwiftUI

public enum ModalPresentationStyle: Hashable, Sendable {
    case sheet(detents: Set<PresentationDetent> = [.large])
    case fullScreenCover
}
```

### ModalNavigation

```swift
// Libraries/Core/Sources/Navigation/ModalNavigation.swift
import SwiftUI

public struct ModalNavigation: Identifiable {
    public let id = UUID()
    public let navigation: AnyNavigation
    public let style: ModalPresentationStyle

    public init(navigation: any NavigationContract, style: ModalPresentationStyle) {
        self.navigation = AnyNavigation(navigation)
        self.style = style
    }

    public var detents: Set<PresentationDetent> {
        if case .sheet(let detents) = style {
            return detents
        }
        return []
    }
}
```

### NavigationCoordinator (Implementation)

```swift
// Libraries/Core/Sources/Navigation/NavigationCoordinator.swift
import Foundation
import SwiftUI

@Observable
public final class NavigationCoordinator: NavigatorContract {
    public var path = NavigationPath()
    public var sheetNavigation: ModalNavigation?
    public var fullScreenCoverNavigation: ModalNavigation?

    private let redirector: (any NavigationRedirectContract)?
    private let onDismiss: (() -> Void)?

    public init(
        redirector: (any NavigationRedirectContract)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.redirector = redirector
        self.onDismiss = onDismiss
    }

    public func navigate(to destination: any NavigationContract) {
        let resolved = resolveRedirect(destination)
        path.append(AnyNavigation(resolved))
    }

    public func present(_ destination: any NavigationContract, style: ModalPresentationStyle) {
        let resolved = resolveRedirect(destination)
        let modal = ModalNavigation(navigation: resolved, style: style)
        switch style {
        case .sheet:
            sheetNavigation = modal
        case .fullScreenCover:
            fullScreenCoverNavigation = modal
        }
    }

    public func dismiss() {
        if fullScreenCoverNavigation != nil {
            fullScreenCoverNavigation = nil
        } else if sheetNavigation != nil {
            sheetNavigation = nil
        } else {
            onDismiss?()
        }
    }

    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }

    // MARK: - Private

    private func resolveRedirect(_ destination: any NavigationContract) -> any NavigationContract {
        if destination is any OutgoingNavigationContract {
            if let redirected = redirector?.redirect(destination) {
                return redirected
            }
            return UnknownNavigation.notFound
        }
        return destination
    }
}
```

### NavigationRedirectContract (Protocol)

```swift
// Libraries/Core/Sources/Navigation/NavigationRedirectContract.swift
import Foundation

public protocol NavigationRedirectContract: Sendable {
    func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)?
}
```

### FeatureContract Protocol

```swift
// Libraries/Core/Sources/Feature/Feature.swift
import SwiftUI

public protocol FeatureContract {
    /// The deep link handler for this feature (optional).
    var deepLinkHandler: (any DeepLinkHandlerContract)? { get }

    /// Creates the main view for this feature.
    func makeMainView(navigator: any NavigatorContract) -> AnyView

    /// Resolves a navigation destination to a view.
    /// Returns nil if this feature doesn't handle the given navigation.
    func resolve(_ navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView?
}

public extension FeatureContract {
    var deepLinkHandler: (any DeepLinkHandlerContract)? { nil }
}
```

**Notes:**
- `deepLinkHandler` is optional with default `nil` implementation
- `makeMainView()` creates the feature's default entry point view
- `resolve()` handles navigation destinations (returns `nil` if not handled)

### DeepLinkHandlerContract (Protocol)

```swift
// Libraries/Core/Sources/Navigation/DeepLinkHandler.swift
import Foundation

public protocol DeepLinkHandlerContract: Sendable {
    var scheme: String { get }
    var host: String { get }
    func resolve(_ url: URL) -> (any NavigationContract)?
}
```

### NavigatorMock (for testing)

```swift
// Libraries/Core/Mocks/NavigatorMock.swift
import ChallengeCore
import Foundation

public final class NavigatorMock: NavigatorContract {
    public private(set) var navigatedDestinations: [any NavigationContract] = []
    public private(set) var presentedModals: [(destination: any NavigationContract, style: ModalPresentationStyle)] = []
    public private(set) var dismissCallCount = 0
    public private(set) var goBackCallCount = 0

    public init() {}

    public func navigate(to destination: any NavigationContract) {
        navigatedDestinations.append(destination)
    }

    public func present(_ destination: any NavigationContract, style: ModalPresentationStyle) {
        presentedModals.append((destination: destination, style: style))
    }

    public func dismiss() {
        dismissCallCount += 1
    }

    public func goBack() {
        goBackCallCount += 1
    }
}
```

---

## Modal Navigation

Modals are presented via `present(_:style:)` and dismissed via `dismiss()`. Each modal gets its own `NavigationStack` for push navigation within the modal. Modals can present other modals recursively.

### ModalPresentationStyle

| Style | Description |
|-------|-------------|
| `.sheet(detents:)` | Presents as a sheet with configurable detents (default: `[.large]`) |
| `.fullScreenCover` | Presents as a full-screen cover |

### Present / Dismiss Behavior

- `present(_:style:)` — sets `sheetNavigation` or `fullScreenCoverNavigation` on the coordinator
- `dismiss()` — priority: fullScreenCover > sheet > parent onDismiss

### Navigator Example with Modal

```swift
protocol FilterNavigatorContract {
    func presentFilter()
    func dismiss()
}

struct FilterNavigator: FilterNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func presentFilter() {
        navigator.present(
            FeatureIncomingNavigation.filter,
            style: .sheet(detents: [.medium, .large])
        )
    }

    func dismiss() {
        navigator.dismiss()
    }
}
```

### NavigationContainerView (AppKit)

Reusable container that encapsulates `NavigationStack` + push destinations + modal bindings. Used by both `RootContainerView` and `ModalContainerView`:

```swift
// AppKit/Sources/Presentation/Views/NavigationContainerView.swift

struct NavigationContainerView<Content: View>: View {
    @Bindable var navigationCoordinator: NavigationCoordinator
    let appContainer: AppContainer
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            content
                .navigationDestination(for: AnyNavigation.self) { navigation in
                    appContainer.resolve(navigation.wrapped, navigator: navigationCoordinator)
                }
        }
        .sheet(item: $navigationCoordinator.sheetNavigation) { modal in
            ModalContainerView(modal: modal, appContainer: appContainer) {
                navigationCoordinator.sheetNavigation = nil
            }
            .presentationDetents(modal.detents)
        }
        .fullScreenCover(item: $navigationCoordinator.fullScreenCoverNavigation) { modal in
            ModalContainerView(modal: modal, appContainer: appContainer) {
                navigationCoordinator.fullScreenCoverNavigation = nil
            }
        }
    }
}
```

### ModalContainerView (AppKit)

Creates its own `NavigationCoordinator` and delegates to `NavigationContainerView`:

```swift
// AppKit/Sources/Presentation/Views/ModalContainerView.swift

struct ModalContainerView: View {
    let modal: ModalNavigation
    let appContainer: AppContainer
    let onDismiss: () -> Void

    @State private var navigationCoordinator: NavigationCoordinator

    init(modal: ModalNavigation, appContainer: AppContainer, onDismiss: @escaping () -> Void) {
        self.modal = modal
        self.appContainer = appContainer
        self.onDismiss = onDismiss
        _navigationCoordinator = State(initialValue: NavigationCoordinator(
            redirector: AppNavigationRedirect(),
            onDismiss: onDismiss
        ))
    }

    var body: some View {
        NavigationContainerView(navigationCoordinator: navigationCoordinator, appContainer: appContainer) {
            appContainer.resolve(modal.navigation.wrapped, navigator: navigationCoordinator)
        }
    }
}
```

### Testing Modal Navigation

```swift
@Test("Present filter presents sheet with correct detents")
func presentFilterPresentsSheet() {
    // Given
    let navigatorMock = NavigatorMock()
    let sut = FilterNavigator(navigator: navigatorMock)

    // When
    sut.presentFilter()

    // Then
    let modal = navigatorMock.presentedModals.first
    let destination = modal?.destination as? FeatureIncomingNavigation
    #expect(destination == .filter)
    #expect(modal?.style == .sheet(detents: [.medium, .large]))
}

@Test("Dismiss calls navigator dismiss")
func dismissCallsNavigatorDismiss() {
    // Given
    let navigatorMock = NavigatorMock()
    let sut = FilterNavigator(navigator: navigatorMock)

    // When
    sut.dismiss()

    // Then
    #expect(navigatorMock.dismissCallCount == 1)
}
```

---

## Feature Navigation

Each feature defines Incoming and optionally Outgoing navigation:

### Incoming Navigation (Destinations the feature handles)

```swift
// Features/{Feature}/Sources/Presentation/Navigation/{Feature}IncomingNavigation.swift
import ChallengeCore

public enum {Feature}IncomingNavigation: IncomingNavigationContract {
    case list
    case detail(identifier: Int)
}
```

### Outgoing Navigation (Destinations to other features)

```swift
// Features/{Feature}/Sources/Presentation/Navigation/{Feature}OutgoingNavigation.swift
import ChallengeCore

public enum {Feature}OutgoingNavigation: OutgoingNavigationContract {
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

struct {Feature}DeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "{feature}"  // e.g., "character"

    func resolve(_ url: URL) -> (any NavigationContract)? {
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
    func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)? {
        switch navigation {
        case let outgoing as HomeOutgoingNavigation:
            return redirect(outgoing)
        default:
            return nil
        }
    }

    // MARK: - Private

    private func redirect(_ navigation: HomeOutgoingNavigation) -> any NavigationContract {
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

    @State private var navigationCoordinator = NavigationCoordinator(redirector: AppNavigationRedirect())

    public init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }

    public var body: some View {
        NavigationContainerView(navigationCoordinator: navigationCoordinator, appContainer: appContainer) {
            appContainer.makeRootView(navigator: navigationCoordinator)
        }
        .onOpenURL { url in
            appContainer.handle(url: url, navigator: navigationCoordinator)
        }
    }
}

/*
#Preview {
    RootContainerView(appContainer: AppContainer())
}
*/
```

**Key Points:**
- Uses `NavigationContainerView` for NavigationStack + push destinations + modal bindings
- Located in `AppKit` module (not `App`) for testability
- Only adds `.onOpenURL` on top of `NavigationContainerView`

### AppContainer (Navigation Resolution)

```swift
// AppKit/Sources/AppContainer.swift

/// Resolves any navigation to a view by iterating through features.
/// Falls back to NotFoundView if no feature can handle the navigation.
public func resolve(
    _ navigation: any NavigationContract,
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

public struct {Feature}Feature: FeatureContract {
    private let container: {Feature}Container

    public init(httpClient: any HTTPClientContract) {
        self.container = {Feature}Container(httpClient: httpClient)
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        {Feature}DeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView({Name}ListView(
            viewModel: container.make{Name}ListViewModel(navigator: navigator)
        ))
    }

    public func resolve(
        _ navigation: any NavigationContract,
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
│       ├── NavigationCoordinator.swift      # @Observable, manages path + modals + redirects
│       ├── NavigatorContract.swift          # Protocol for navigation (push + modal)
│       ├── NavigationRedirectContract.swift # Protocol for redirects
│       ├── Navigation.swift                 # Base protocol
│       ├── AnyNavigation.swift              # Type-erased wrapper for NavigationPath
│       ├── ModalPresentationStyle.swift     # Sheet/fullScreenCover enum
│       ├── ModalNavigation.swift            # Modal state (Identifiable)
│       └── DeepLinkHandler.swift            # Protocol for deep links
└── Mocks/
    ├── NavigatorMock.swift
    └── TrackerMock.swift

AppKit/Sources/                              # Note: AppKit, not App (for testability)
├── AppContainer.swift                       # resolve() and handle(url:)
└── Presentation/
    ├── Navigation/
    │   └── AppNavigationRedirect.swift      # Connects features via redirects
    └── Views/
        ├── NavigationContainerView.swift        # Reusable NavigationStack + push + modal bindings
        ├── RootContainerView.swift          # Root level, uses NavigationContainerView + onOpenURL
        └── ModalContainerView.swift         # Creates own NavigationCoordinator, uses NavigationContainerView

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
│           ├── Navigator/
│           │   ├── {Screen}NavigatorContract.swift
│           │   └── {Screen}Navigator.swift
│           └── Tracker/                     # Same pattern as Navigator
│               ├── {Screen}TrackerContract.swift
│               ├── {Screen}Tracker.swift
│               └── {Screen}Event.swift
└── Tests/
    └── Unit/
        └── Presentation/
            ├── Navigation/
            │   └── {Feature}DeepLinkHandlerTests.swift
            └── {Screen}/
                ├── Navigator/
                │   └── {Screen}NavigatorTests.swift
                └── Tracker/
                    ├── {Screen}TrackerTests.swift
                    └── {Screen}EventTests.swift
```

---

## Checklist

### Core Setup
- [ ] Core has `NavigatorContract` protocol (navigate, present, dismiss, goBack)
- [ ] Core has `NavigationRedirectContract` protocol
- [ ] Core has `NavigationCoordinator` (@Observable, manages path + modals + redirects)
- [ ] Core has `NavigationContract` protocol
- [ ] Core has `AnyNavigation` type-erased wrapper
- [ ] Core has `ModalPresentationStyle` enum (sheet, fullScreenCover)
- [ ] Core has `ModalNavigation` struct (Identifiable, wraps navigation + style)
- [ ] Core has `DeepLinkHandlerContract` protocol
- [ ] Core has `FeatureContract` protocol with `makeMainView()` and `resolve()` methods
- [ ] Core has `NavigatorMock` for testing (tracks navigatedDestinations, presentedModals, dismissCallCount, goBackCallCount)

### AppKit Configuration
- [ ] `Project.swift` has `CFBundleURLTypes` with URL scheme (e.g., `challenge`)
- [ ] `AppNavigationRedirect` in `AppKit/Sources/Presentation/Navigation/`
- [ ] `RootContainerView` in `AppKit/Sources/Presentation/Views/`
- [ ] `RootContainerView` uses `.navigationDestination(for: AnyNavigation.self)`
- [ ] `NavigationContainerView` in `AppKit/Sources/Presentation/Views/` (NavigationStack + push + modals)
- [ ] `RootContainerView` uses `NavigationContainerView` + `.onOpenURL`
- [ ] `ModalContainerView` in `AppKit/Sources/Presentation/Views/` (creates own coordinator, uses `NavigationContainerView`)
- [ ] `AppContainer.resolve()` iterates features and falls back to NotFoundView
- [ ] `AppContainer.handle(url:navigator:)` resolves deep links via feature handlers

### Feature Implementation
- [ ] Feature has `{Feature}IncomingNavigation` in `Presentation/Navigation/`
- [ ] Feature has `{Feature}OutgoingNavigation` for cross-feature navigation (if needed)
- [ ] Feature has `{Feature}DeepLinkHandler` returning `IncomingNavigationContract` (if deep links needed)
- [ ] Feature implements `makeMainView(navigator:)` returning default entry point
- [ ] Feature implements `resolve(_:navigator:)` returning view or nil
- [ ] Each screen has `NavigatorContract` and `Navigator`
- [ ] Each screen has `TrackerContract`, `Tracker`, and `Event` (same pattern as Navigator)
- [ ] Navigator uses `IncomingNavigationContract` for internal, `OutgoingNavigationContract` for external
- [ ] Container factories receive `navigator: any NavigatorContract`
- [ ] ViewModel receives specific `NavigatorContract` (not generic)

### Testing
- [ ] Tests use `NavigatorMock` to verify navigation
- [ ] Navigator tests verify correct Navigation enum is used
- [ ] AppNavigationRedirect tests verify Outgoing → Incoming mapping
- [ ] DeepLinkHandler tests verify URL → IncomingNavigationContract resolution
