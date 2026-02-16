# ChallengeAppKit

Application infrastructure module providing the composition root and navigation setup.

## Overview

ChallengeAppKit contains the `AppContainer` (composition root), navigation container infrastructure (`NavigationContainerView`, `ModalContainerView`, `RootContainerView`), and cross-feature navigation redirect. It's separated from the App target to enable unit testing without `TEST_HOST`.

## Default Actor Isolation

| Setting | Value |
|---------|-------|
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` (project default) |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` |

All types are **MainActor-isolated by default** — no explicit `@MainActor` needed. Types that must run off the main thread opt out with `nonisolated`.

## Structure

```
AppKit/
├── Sources/
│   ├── AppContainer.swift
│   ├── Data/
│   │   ├── AppEnvironment+API.swift
│   │   └── LaunchEnvironment.swift
│   └── Presentation/
│       ├── Navigation/
│       │   └── AppNavigationRedirect.swift
│       └── Views/
│           ├── NavigationContainerView.swift
│           ├── ModalContainerView.swift
│           └── RootContainerView.swift
└── Tests/
    ├── Unit/
    │   ├── AppContainerTests.swift
    │   ├── Data/
    │   │   ├── AppEnvironment+APITests.swift
    │   │   └── LaunchEnvironmentTests.swift
    │   └── Presentation/
    │       ├── Navigation/
    │       │   └── AppNavigationRedirectTests.swift
    │       └── Views/
    │           ├── ModalContainerViewTests.swift
    │           └── RootContainerViewTests.swift
    └── Snapshots/
        └── Presentation/
            ├── ModalContainerViewSnapshotTests.swift
            └── RootViewSnapshotTests.swift
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeAppKit` | Framework | App infrastructure |
| `ChallengeAppKitTests` | Test | Unit tests |
| `ChallengeAppKitSnapshotTests` | Test | Snapshot tests |

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Navigation protocols |
| `ChallengeNetworking` | HTTP client |
| `ChallengeCharacter` | Character feature |
| `ChallengeEpisode` | Episode feature |
| `ChallengeHome` | Home feature |
| `ChallengeSystem` | System feature (fallback) |

## Components

### AppContainer

Composition root that creates and wires all dependencies:

```swift
public struct AppContainer {
    private let launchEnvironment: LaunchEnvironment
    private let httpClient: any HTTPClientContract
    private let tracker: any TrackerContract
    let imageLoader: any ImageLoaderContract

    private let homeFeature: HomeFeature
    private let characterFeature: CharacterFeature
    private let episodeFeature: EpisodeFeature
    private let systemFeature: SystemFeature

    func resolveView(for navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView
    func handle(url: URL, navigator: any NavigatorContract)
    func makeRootView(navigator: any NavigatorContract) -> AnyView
}
```

Tracking providers are registered via a static factory method:

```swift
private extension AppContainer {
    static func makeTracker() -> Tracker {
        let providers: [any TrackingProviderContract] = [
            ConsoleTrackingProvider()
        ]
        providers.forEach { $0.configure() }
        return Tracker(providers: providers)
    }
}
```

### AppNavigationRedirect

Connects outgoing navigation to incoming navigation across features:

```swift
public struct AppNavigationRedirect: NavigationRedirectContract {
    public func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)?
}
```

### NavigationContainerView

Reusable generic view that encapsulates `NavigationStack` with push destinations and modal bindings (`.sheet`, `.fullScreenCover`). Used by both `RootContainerView` and `ModalContainerView` to avoid duplicating navigation infrastructure.

**How it works step by step:**

1. Receives a `NavigationCoordinator` and `AppContainer` as parameters, plus a `@ViewBuilder` content closure
2. Wraps the content in a `NavigationStack` bound to the coordinator's `path`
3. Registers `.navigationDestination(for: AnyNavigation.self)` to resolve push destinations via `appContainer.resolve()`
4. Binds `.sheet(item: $coordinator.sheetNavigation)` — when `sheetNavigation` becomes non-nil, presents a `ModalContainerView`
5. Binds `.fullScreenCover(item: $coordinator.fullScreenCoverNavigation)` — same for full-screen modals
6. Each modal's `onDismiss` closure nils the parent coordinator's state, enabling programmatic dismiss from within the modal

```swift
struct NavigationContainerView<Content: View>: View {
    @Bindable var navigationCoordinator: NavigationCoordinator
    let appContainer: AppContainer
    @ViewBuilder let content: Content
}
```

### ModalContainerView

Recursive container that creates its own `NavigationCoordinator` for each modal presentation. This enables push navigation within modals and nested modal presentations (modals inside modals).

**How it works step by step:**

1. Receives a `ModalNavigation` (the destination + style), an `AppContainer`, and an `onDismiss` closure
2. Creates a **new** `NavigationCoordinator` with:
   - `redirector: AppNavigationRedirect()` — so cross-feature navigation works inside modals
   - `onDismiss: onDismiss` — when `dismiss()` is called inside the modal with no sub-modals, this closure fires, which nils the parent's modal state
3. Delegates to `NavigationContainerView`, passing the modal's resolved view as content
4. Because `NavigationContainerView` itself binds `.sheet` and `.fullScreenCover`, the modal can present nested modals — the structure is **recursive**

```
RootContainerView
  └── NavigationContainerView (root coordinator)
        ├── NavigationStack (push navigation)
        ├── .sheet → ModalContainerView (own coordinator)
        │     └── NavigationContainerView (modal coordinator)
        │           ├── NavigationStack (push inside modal)
        │           ├── .sheet → ModalContainerView (nested)
        │           └── .fullScreenCover → ModalContainerView (nested)
        └── .fullScreenCover → ModalContainerView (own coordinator)
              └── NavigationContainerView (modal coordinator)
                    └── ...
```

**Dismiss chain:** When code inside a modal calls `navigator.dismiss()`:
1. The modal's coordinator checks: do I have a fullScreenCover? → dismiss it
2. Do I have a sheet? → dismiss it
3. No modals? → call `onDismiss()`, which nils the **parent's** modal state, causing SwiftUI to dismiss this modal

```swift
struct ModalContainerView: View {
    let modal: ModalNavigation
    let appContainer: AppContainer
    let onDismiss: () -> Void
    @State private var navigationCoordinator: NavigationCoordinator
}
```

### Why `onDismiss` nils the parent's modal state

In `NavigationContainerView`, each modal's `onDismiss` closure explicitly sets `navigationCoordinator.sheetNavigation = nil` or `navigationCoordinator.fullScreenCoverNavigation = nil`. This is necessary because there are **two ways** to close a modal, and each requires different handling:

**1. User swipe-dismiss (interactive gesture)**

SwiftUI handles this automatically. When the user drags a sheet down, SwiftUI sets the `.sheet(item:)` binding to `nil` internally. No action needed from our side.

**2. Programmatic dismiss (`navigator.dismiss()` from inside the modal)**

This is where the `onDismiss` closure is essential. The modal has its **own** `NavigationCoordinator` which is independent from the parent's. When code inside the modal calls `navigator.dismiss()`:

```
Code inside modal calls: navigator.dismiss()
    ↓
Modal's NavigationCoordinator: no sub-modals → onDismiss()
    ↓
onDismiss = { navigationCoordinator.sheetNavigation = nil }  ← parent's coordinator
    ↓
Parent's binding changes to nil → SwiftUI dismisses the sheet
```

Without this closure, the programmatic dismiss from inside the modal would have **no way to communicate** to the parent coordinator that the modal should close. The child coordinator doesn't have a reference to the parent — the `onDismiss` closure is the bridge between them.

**In summary:** SwiftUI handles the swipe-dismiss path. The `onDismiss` closure handles the programmatic dismiss path by propagating the intent from the child coordinator to the parent's state.

### RootContainerView

Root navigation view. Uses `NavigationContainerView` and adds `.onOpenURL` for deep link handling:

```swift
public struct RootContainerView: View {
    public let appContainer: AppContainer
    // Uses NavigationCoordinator with AppNavigationRedirect
    // Delegates to NavigationContainerView + .onOpenURL
}
```

## Testing

```bash
tuist test ChallengeAppKit
```
