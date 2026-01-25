# ChallengeCore

Core infrastructure module providing foundational services for the application.

## Overview

ChallengeCore contains the essential building blocks used across all features: navigation, routing, deep linking, image loading, and app environment configuration. This module has no external dependencies and serves as the foundation layer.

## Structure

```
Core/
├── Sources/
│   ├── AppEnvironment/
│   │   └── AppEnvironment.swift
│   ├── Navigation/
│   │   ├── RouterContract.swift
│   │   ├── Router.swift
│   │   ├── Navigation.swift
│   │   ├── DeepLinkHandler.swift
│   │   └── DeepLinkRegistry.swift
│   ├── ImageLoader/
│   │   ├── ImageLoaderContract.swift
│   │   ├── CachedImageLoader.swift
│   │   └── ImageLoaderEnvironment.swift
│   ├── Feature/
│   │   ├── Feature.swift
│   │   └── View+FeatureNavigation.swift
│   └── Extensions/
│       └── URL+QueryParameter.swift
├── Mocks/
│   ├── ImageLoaderMock.swift
│   ├── RouterMock.swift
│   └── Bundle+JSON.swift
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

#### RouterContract

Protocol defining navigation capabilities:

```swift
public protocol RouterContract {
    func navigate(to destination: any Navigation)
    func navigate(to url: URL?)
    func goBack()
}
```

#### Router

`NavigationPath`-based implementation that manages the navigation stack and coordinates with deep link handlers.

#### Navigation Protocol

Marker protocol for type-safe navigation destinations:

```swift
public protocol Navigation: Hashable {}
```

#### Deep Linking

- `DeepLinkHandler` - Protocol for handling URL-based navigation
- `DeepLinkRegistry` - Singleton registry for deep link handlers

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

#### ImageLoaderEnvironment

SwiftUI environment key for injecting the image loader.

### Feature Protocol

Protocol for feature modules to implement navigation destinations and deep link registration:

```swift
public protocol Feature {
    func registerDeepLinks()
    func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView
}
```

### App Environment

Global configuration for the application (API URLs, environment settings, etc.).

## Usage

### Navigation

```swift
// Navigate to a destination
router.navigate(to: CharacterNavigation.list)

// Navigate via deep link
router.navigate(to: URL(string: "challenge://characters/123"))

// Go back
router.goBack()
```

### Image Loading

```swift
// In a View
@Environment(\.imageLoader) private var imageLoader

// Load image
let image = try await imageLoader.loadImage(from: url)
```

### Feature Registration

```swift
// Register deep links
feature.registerDeepLinks()

// Apply navigation destinations
feature.applyNavigationDestination(to: view, router: router)
```

## Mocks

Available in `ChallengeCoreMocks` target for testing:

| Mock | Purpose |
|------|---------|
| `RouterMock` | Captures navigation calls |
| `ImageLoaderMock` | Returns stub images |
| `Bundle+JSON` | Loads JSON fixtures from test bundles |

## Testing

Run tests with:

```bash
tuist test ChallengeCore
```
