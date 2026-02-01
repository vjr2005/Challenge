# Challenge App

Main application target that serves as the entry point for the iOS application.

## Overview

The Challenge app is the composition root that wires together all feature modules and provides the main application lifecycle management. It follows the MVVM + Clean Architecture pattern with dependency injection.

## Structure

```
App/
├── Sources/
│   ├── ChallengeApp.swift           # @main entry point
│   ├── AppContainer.swift           # Dependency injection container
│   ├── Data/
│   │   └── AppEnvironment+API.swift # API configuration
│   ├── Presentation/
│   │   └── Views/
│   │       └── RootView.swift       # Root navigation view
│   └── Resources/
│       ├── LaunchScreen.storyboard
│       └── Assets.xcassets/
├── Tests/
│   └── ...                          # Unit and snapshot tests
└── UITests/
    └── ...                          # UI tests
```

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Navigation, routing, app environment |
| `ChallengeCharacter` | Character feature module |
| `ChallengeHome` | Home feature module |

## Key Components

### ChallengeApp

The `@main` entry point that initializes the `AppContainer` and creates the root view:

```swift
@main
struct ChallengeApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            container.makeRootView()
        }
    }
}
```

### AppContainer

The dependency injection container responsible for:
- Creating and configuring the HTTP client
- Initializing feature modules
- Wiring up the router and deep link handlers
- Building the root view hierarchy

### RootView

The root navigation view that:
- Sets up `NavigationStack` with the router's path
- Applies navigation destinations from all features
- Handles deep link navigation

## Testing

### Unit Tests (`ChallengeTests`)

- `AppEnvironment+APITests.swift` - Tests for API configuration

### Snapshot Tests

- `RootViewSnapshotTests.swift` - Visual regression tests for root view

### UI Tests (`ChallengeUITests`)

UI tests using the Robot pattern:

| Robot | Purpose |
|-------|---------|
| `Robot.swift` | Base robot with common actions |
| `HomeRobot.swift` | Home screen interactions |
| `CharacterListRobot.swift` | Character list interactions |
| `CharacterDetailRobot.swift` | Character detail interactions |

**Test Files:**
- `CharacterFlowUITests.swift` - Character navigation flows
- `DeepLinkUITests.swift` - Deep link handling tests

## Running the App

```bash
# Generate Xcode project
tuist generate

# Build and run
tuist build

# Run tests
tuist test
```
