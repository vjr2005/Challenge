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
│   ├── Data/
│   │   ├── CachePolicy.swift
│   │   ├── CachePolicyExecutor.swift
│   │   └── MapperContract.swift
│   ├── Feature/
│   │   └── Feature.swift
│   ├── ImageLoader/
│   │   ├── ImageLoaderContract.swift
│   │   ├── CachedImageLoader.swift
│   │   ├── ImageLoaderEnvironment.swift
│   │   ├── DiskCache/
│   │   │   ├── ImageDiskCacheContract.swift
│   │   │   ├── ImageDiskCache.swift
│   │   │   ├── DiskCacheConfiguration.swift
│   │   │   ├── FileSystemContract.swift
│   │   │   └── FileSystem.swift
│   │   └── MemoryCache/
│   │       ├── ImageMemoryCacheContract.swift
│   │       └── ImageMemoryCache.swift
│   ├── Navigation/
│   │   ├── AnyNavigation.swift
│   │   ├── DeepLinkHandler.swift
│   │   ├── ModalNavigation.swift
│   │   ├── ModalPresentationStyle.swift
│   │   ├── Navigation.swift
│   │   ├── NavigationCoordinator.swift
│   │   ├── NavigationRedirectContract.swift
│   │   ├── NavigatorContract.swift
│   │   └── UnknownNavigation.swift
│   ├── Tracking/
│   │   ├── TrackerContract.swift
│   │   ├── Tracker.swift
│   │   ├── TrackingEventContract.swift
│   │   └── Providers/
│   │       ├── TrackingProviderContract.swift
│   │       └── ConsoleTrackingProvider.swift
│   └── Extensions/
│       ├── URL+QueryParameter.swift
│       └── View+OnFirstAppear.swift
├── Mocks/
│   ├── Bundle+JSON.swift
│   ├── ImageLoaderMock.swift
│   ├── NavigatorMock.swift
│   ├── TrackerMock.swift
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

Protocol defining push and modal navigation capabilities:

```swift
public protocol NavigatorContract {
    func navigate(to destination: any NavigationContract)
    func present(_ destination: any NavigationContract, style: ModalPresentationStyle)
    func dismiss()
    func goBack()
}
```

#### ModalPresentationStyle

Defines how a modal is presented:

```swift
public enum ModalPresentationStyle: Hashable {
    case sheet(detents: Set<PresentationDetent> = [.large])
    case fullScreenCover
}
```

#### ModalNavigation

Wraps a navigation destination with its presentation style, used as the `item` for SwiftUI's `.sheet(item:)` and `.fullScreenCover(item:)`:

```swift
public struct ModalNavigation: Identifiable {
    public let id: UUID
    public let navigation: AnyNavigation
    public let style: ModalPresentationStyle
    public var detents: Set<PresentationDetent>
}
```

#### NavigationCoordinator

`@Observable` implementation using `NavigationPath` that manages the navigation stack, modal presentations, and handles redirects. Exposes `sheetNavigation` and `fullScreenCoverNavigation` for SwiftUI bindings.

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
public protocol ImageLoaderContract: Sendable {
    func cachedImage(for url: URL) -> UIImage?
    func image(for url: URL) async -> UIImage?
    func removeCachedImage(for url: URL) async
    func clearCache() async
}
```

#### CachedImageLoader

Two-tier image loader with in-memory caching, disk caching, and deduplication of in-flight network requests. Depends on `ImageMemoryCacheContract` and `ImageDiskCacheContract` abstractions (Dependency Inversion), both injectable via the internal init for testing.

Lookup order: memory cache → disk cache → network. On network success, the image is stored in both caches.

#### MemoryCache

In-memory image cache backed by `NSCache`:

- **`ImageMemoryCacheContract`** — Protocol for in-memory image cache operations (get, set, remove, clear).
- **`ImageMemoryCache`** — `final class` implementation wrapping `NSCache`. Not an actor because `NSCache` is already thread-safe and `cachedImage(for:)` must remain synchronous.

#### DiskCache

Disk-based image cache with TTL expiration and LRU eviction:

- **`ImageDiskCacheContract`** — `: Actor` protocol defining disk cache operations (get, store, remove, clear).
- **`ImageDiskCache`** — `actor` that manages cached files in the `Caches/ImageCache` directory. Zero suspension points internally: all `FileSystem` calls are synchronous within the actor's isolation, making every method an atomic critical section with no reentrancy risk.
- **`FileSystemContract`** — `: Sendable` protocol with `nonisolated` methods. This design eliminates actor-to-actor hops that would introduce suspension points.
- **`FileSystem`** — `struct` wrapping `FileManager` (thread-safe but not `Sendable`).
- **`DiskCacheConfiguration`** — Configurable `maxSize` (default 100 MB), `timeToLive` (default 7 days), and cache directory.

### Data

Shared abstractions for the data layer:

- **`MapperContract`** — Generic protocol for mapping between DTOs and domain models.
- **`CachePolicy`** — Enum controlling cache behavior: `.localFirst`, `.remoteFirst`, `.noCache`.
- **`CachePolicyExecutor`** — Stateless struct that executes data fetch operations using a `CachePolicy`. Repositories delegate cache strategy logic to this executor, eliminating duplicated cache implementations. Accepts generic closures for remote fetch, cache read/write, DTO-to-domain mapping, and error mapping (transport errors to domain errors).

### FeatureContract Protocol

Protocol for feature modules to implement navigation and deep link handling:

```swift
public protocol FeatureContract {
    var deepLinkHandler: (any DeepLinkHandlerContract)? { get }
    func makeMainView(navigator: any NavigatorContract) -> AnyView
    func resolve(_ navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView?
}
```

### Tracking

#### TrackerContract

Protocol defining tracking capabilities:

```swift
public protocol TrackerContract: Sendable {
    func track(_ event: any TrackingEventContract)
}
```

#### Tracker

Implementation that dispatches events to registered providers:

```swift
public struct Tracker: TrackerContract {
    public init(providers: [any TrackingProviderContract])
    public func track(_ event: any TrackingEventContract)
}
```

#### TrackingEventContract

Protocol for tracking events with optional properties:

```swift
public protocol TrackingEventContract: Sendable {
    var name: String { get }
    var properties: [String: String] { get }
}
```

A default extension provides an empty dictionary for `properties`, so events without properties can omit the implementation.

#### TrackingProviderContract

Protocol for tracking backends. Inherits from `TrackerContract` and adds lifecycle management:

```swift
public protocol TrackingProviderContract: TrackerContract {
    func configure()
}
```

A default extension provides an empty `configure()` implementation for providers that don't need initialization.

#### ConsoleTrackingProvider

Development provider that logs events to the console using `os_log`.

### Extensions

- **`View+OnFirstAppear`** — `.onFirstAppear` modifier that executes an async action only the first time the view appears (equivalent to UIKit's `viewDidLoad`).
- **`URL+QueryParameter`** — URL query parameter helpers.

### App Environment

Global configuration for the application (API URLs, environment settings).

## Usage

### Navigation

```swift
// Push navigation
navigator.navigate(to: CharacterIncomingNavigation.list)

// Modal presentation
navigator.present(CharacterIncomingNavigation.filter, style: .sheet(detents: [.medium, .large]))
navigator.present(CharacterIncomingNavigation.settings, style: .fullScreenCover)

// Dismiss current modal (or call parent onDismiss if no modals)
navigator.dismiss()

// Go back (pop from NavigationStack)
navigator.goBack()
```

### Image Loading

```swift
@Environment(\.imageLoader) private var imageLoader

let image = await imageLoader.image(for: url)
```

## Mocks

Available in `ChallengeCoreMocks` target for testing:

| Mock | Purpose |
|------|---------|
| `NavigatorMock` | Captures navigation, modal, and dismiss calls |
| `TrackerMock` | Captures tracked events |
| `ImageLoaderMock` | Returns stub images |
| `Bundle+JSON` | Loads JSON fixtures from test bundles |

## Testing

```bash
tuist test ChallengeCore
```
