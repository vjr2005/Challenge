# Challenge App

Main application target that serves as the entry point for the iOS application.

## Overview

The Challenge app is the minimal entry point that creates the `AppContainer` and displays `RootContainerView` from `ChallengeAppKit`.

## Structure

```
App/
├── Sources/
│   └── ChallengeApp.swift
├── Tests/
│   ├── Shared/
│   │   ├── Robots/
│   │   ├── Scenarios/
│   │   ├── Stubs/
│   │   └── Fixtures/
│   └── UI/
│       ├── CharacterFlowUITests.swift
│       └── DeepLinkUITests.swift
└── Resources/
    ├── LaunchScreen.storyboard
    └── Assets.xcassets/
```

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeAppKit` | App container, root view, navigation |

## Entry Point

```swift
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

`RootContainerView` is the root of the navigation container hierarchy. It delegates to `NavigationContainerView`, which encapsulates the `NavigationStack` with push destinations and modal bindings (`.sheet`, `.fullScreenCover`). Each modal creates its own `NavigationCoordinator`, enabling push navigation within modals and recursive modal nesting.

> **Important:** The modal dismiss mechanism relies on explicit `onDismiss` closures that nil the parent coordinator's modal state. This is necessary because programmatic dismiss (via `navigator.dismiss()`) cannot communicate to the parent without this bridge. For a detailed explanation of how this works and why it's needed, see [AppKit README — Why `onDismiss` nils the parent's modal state](../AppKit/README.md#why-ondismiss-nils-the-parents-modal-state).

## UI Tests

UI tests use [SwiftMockServer](https://github.com/vjr2005/SwiftMockServer) for HTTP mocking and the Robot pattern for UI interactions.

| Robot | Purpose |
|-------|---------|
| `HomeRobot` | Home screen interactions |
| `CharacterListRobot` | Character list interactions |
| `CharacterDetailRobot` | Character detail interactions |
| `NotFoundRobot` | Not found screen interactions |

Mock server configurations are extracted into reusable scenarios in `UITestCase+Scenarios.swift`.

**Test Files:**
- `CharacterFlowUITests.swift` - Character navigation flows
- `DeepLinkUITests.swift` - Deep link handling tests

## Running

```bash
# Generate Xcode project
tuist generate

# Build
tuist build

# Run tests
tuist test
```
