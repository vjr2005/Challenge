# ChallengeCore

Core infrastructure module providing foundational services for the application.

## Overview

ChallengeCore contains the essential building blocks used across all features: navigation, deep linking, image loading, and app environment configuration. This module has no external dependencies and serves as the foundation layer.

## Structure

```
Core/
├── Sources/
│   ├── AppEnvironment/
│   │   └── AppEnvironment.swift
│   ├── Feature/
│   │   └── Feature.swift
│   ├── ImageLoader/
│   │   ├── ImageLoaderContract.swift
│   │   ├── CachedImageLoader.swift
│   │   └── ImageLoaderEnvironment.swift
│   ├── Navigation/
│   │   ├── AnyNavigation.swift
│   │   ├── DeepLinkHandler.swift
│   │   ├── Navigation.swift
│   │   ├── NavigationCoordinator.swift
│   │   ├── NavigationRedirectContract.swift
│   │   ├── NavigatorContract.swift
│   │   └── UnknownNavigation.swift
│   └── Extensions/
│       └── URL+QueryParameter.swift
├── Mocks/
│   ├── Bundle+JSON.swift
│   ├── ImageLoaderMock.swift
│   ├── NavigatorMock.swift
│   ├── URLProtocolMock.swift
│   └── URLSession+Mock.swift
└── Tests/
    └── ...
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeCore` | Framework | Main library code |
| `ChallengeCoreTests` | Test | Unit tests |
| `ChallengeCoreMocks` | Framework | Test doubles for other modules |

## Components

### Navigation

#### NavigatorContract

Protocol defining navigation capabilities:

```swift
public protocol NavigatorContract {
    func navigate(to destination: any NavigationContract)
    func goBack()
}
```

#### NavigationCoordinator

`@Observable` implementation using `NavigationPath` that manages the navigation stack and handles redirects.

#### NavigationContract

Protocols for type-safe navigation destinations:

```swift
nonisolated public protocol NavigationContract: Hashable, Sendable {}
nonisolated public protocol IncomingNavigationContract: NavigationContract {}
nonisolated public protocol OutgoingNavigationContract: NavigationContract {}
```

#### Deep Linking

- `DeepLinkHandlerContract` - Protocol for handling URL-based navigation

### Image Loading

#### ImageLoaderContract

Protocol for async image loading:

```swift
public protocol ImageLoaderContract {
    func loadImage(from url: URL) async throws -> Image
}
```

#### CachedImageLoader

In-memory caching implementation using `NSCache` with configurable limits.

### FeatureContract Protocol

Protocol for feature modules to implement navigation and deep link handling:

```swift
public protocol FeatureContract {
    var deepLinkHandler: (any DeepLinkHandlerContract)? { get }
    func makeMainView(navigator: any NavigatorContract) -> AnyView
    func resolve(_ navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView?
}
```

### App Environment

Global configuration for the application (API URLs, environment settings).

## Usage

### Navigation

```swift
// Navigate to a destination
navigator.navigate(to: CharacterIncomingNavigation.list)

// Go back
navigator.goBack()
```

### Image Loading

```swift
@Environment(\.imageLoader) private var imageLoader

let image = try await imageLoader.loadImage(from: url)
```

## Mocks

Available in `ChallengeCoreMocks` target for testing:

| Mock | Purpose |
|------|---------|
| `NavigatorMock` | Captures navigation calls |
| `ImageLoaderMock` | Returns stub images |
| `Bundle+JSON` | Loads JSON fixtures from test bundles |

## Testing

```bash
tuist test ChallengeCore
```
