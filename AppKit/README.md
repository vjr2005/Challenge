# ChallengeAppKit

Application infrastructure module providing the composition root and navigation setup.

## Overview

ChallengeAppKit contains the `AppContainer` (composition root), `RootContainerView`, and cross-feature navigation redirect. It's separated from the App target to enable unit testing without `TEST_HOST`.

## Structure

```
AppKit/
├── Sources/
│   ├── AppContainer.swift
│   ├── Data/
│   │   └── AppEnvironment+API.swift
│   └── Presentation/
│       ├── Navigation/
│       │   └── AppNavigationRedirect.swift
│       └── Views/
│           └── RootContainerView.swift
└── Tests/
    ├── Unit/
    │   └── Presentation/
    │       ├── Navigation/
    │       │   └── AppContainerNavigationTests.swift
    │       └── Views/
    │           └── RootContainerViewTests.swift
    └── Snapshots/
        └── Presentation/
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
| `ChallengeHome` | Home feature |
| `ChallengeSystem` | System feature (fallback) |

## Components

### AppContainer

Composition root that creates and wires all dependencies:

```swift
public struct AppContainer: Sendable {
    public let httpClient: any HTTPClientContract
    public var features: [any FeatureContract]

    public func resolve(_ navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView
    public func handle(url: URL, navigator: any NavigatorContract)
    public func makeRootView(navigator: any NavigatorContract) -> AnyView
}
```

### AppNavigationRedirect

Connects outgoing navigation to incoming navigation across features:

```swift
public struct AppNavigationRedirect: NavigationRedirectContract {
    public func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)?
}
```

### RootContainerView

Root navigation view using `NavigationStack`:

```swift
public struct RootContainerView: View {
    public let appContainer: AppContainer
    // Uses NavigationCoordinator with AppNavigationRedirect
}
```

## Testing

```bash
tuist test ChallengeAppKit
```
