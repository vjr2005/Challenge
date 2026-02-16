# Challenge App

Main application target that serves as the entry point for the iOS application.

## Overview

The Challenge app is the minimal entry point that creates the `AppContainer` and displays `RootContainerView` from `ChallengeAppKit`.

## Default Actor Isolation

| Setting | Value |
|---------|-------|
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` (project default) |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` |

All types are **MainActor-isolated by default** — no explicit `@MainActor` needed. Types that must run off the main thread opt out with `nonisolated`.

## Structure

```
App/
├── Sources/
│   ├── ChallengeApp.swift
│   └── Resources/
│       ├── LaunchScreen.storyboard
│       └── Assets.xcassets/
└── Tests/
    ├── Shared/
    │   ├── Robots/
    │   │   ├── Robot.swift
    │   │   ├── AboutRobot.swift
    │   │   ├── CharacterDetailRobot.swift
    │   │   ├── CharacterEpisodesRobot.swift
    │   │   ├── CharacterFilterRobot.swift
    │   │   ├── CharacterListRobot.swift
    │   │   ├── HomeRobot.swift
    │   │   └── NotFoundRobot.swift
    │   ├── Scenarios/
    │   │   └── UITestCase+Scenarios.swift
    │   ├── Stubs/
    │   ├── Extensions/
    │   ├── Fixtures/
    │   └── Resources/
    └── UI/
        ├── CharacterDetailUITests.swift
        ├── CharacterEpisodesUITests.swift
        ├── CharacterListUITests.swift
        ├── HomeUITests.swift
        └── NotFoundUITests.swift
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
| `Robot` | Base robot protocol |
| `AboutRobot` | About screen interactions |
| `CharacterDetailRobot` | Character detail interactions |
| `CharacterEpisodesRobot` | Character episodes interactions |
| `CharacterFilterRobot` | Character filter interactions |
| `CharacterListRobot` | Character list interactions |
| `HomeRobot` | Home screen interactions |
| `NotFoundRobot` | Not found screen interactions |

Mock server configurations are extracted into reusable scenarios in `UITestCase+Scenarios.swift`.

**Test Files:**
- `CharacterDetailUITests.swift` - Character detail screen tests
- `CharacterEpisodesUITests.swift` - Character episodes screen tests
- `CharacterListUITests.swift` - Character list screen tests
- `HomeUITests.swift` - Home screen tests
- `NotFoundUITests.swift` - Not found screen tests

## Running

```bash
# Generate Xcode project
tuist generate

# Build
tuist build

# Run tests
tuist test
```
