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

## UI Tests

UI tests use [SwiftMockServer](https://github.com/nicklama/SwiftMockServer) for HTTP mocking and the Robot pattern for UI interactions.

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
