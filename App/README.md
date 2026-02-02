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

UI tests use the Robot pattern with a local HTTP stub server ([Swifter](https://github.com/httpswift/swifter)) to mock API responses.

### Components

| Component | Purpose |
|-----------|---------|
| `UITestCase` | Base class with StubServer lifecycle |
| `StubServer` | Local HTTP server for mocking API |
| `HomeRobot` | Home screen interactions |
| `CharacterListRobot` | Character list interactions |
| `CharacterDetailRobot` | Character detail interactions |
| `NotFoundRobot` | Not found screen interactions |

### Test Files

| File | Description |
|------|-------------|
| `CharacterFlowUITests.swift` | Character navigation flows |
| `DeepLinkUITests.swift` | Deep link handling tests |

### Shared Resources

| Directory | Purpose |
|-----------|---------|
| `Shared/Robots/` | Robot implementations |
| `Shared/StubServer/` | HTTP stub server |
| `Shared/Fixtures/` | JSON response fixtures |
| `Shared/Stubs/` | Test data helpers |

## Running

```bash
# Generate Xcode project
tuist generate

# Build
tuist build

# Run tests
tuist test
```
