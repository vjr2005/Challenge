# AppContainer (Composition Root)

## AppContainer

```swift
// AppKit/Sources/AppContainer.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import ChallengeNetworking
import ChallengeSystem
import SwiftUI

public struct AppContainer {
    // MARK: - Shared Dependencies

    public let launchEnvironment: LaunchEnvironment
    public let httpClient: any HTTPClientContract
    public let tracker: any TrackerContract
    public let imageLoader: any ImageLoaderContract

    // MARK: - Features

    private let homeFeature: HomeFeature
    private let characterFeature: CharacterFeature
    private let systemFeature: SystemFeature

    public var features: [any FeatureContract] {
        [homeFeature, characterFeature, systemFeature]
    }

    // MARK: - Init

    public init(
        launchEnvironment: LaunchEnvironment = LaunchEnvironment(),
        httpClient: (any HTTPClientContract)? = nil,
        tracker: (any TrackerContract)? = nil,
        imageLoader: (any ImageLoaderContract)? = nil
    ) {
        self.launchEnvironment = launchEnvironment
        self.imageLoader = imageLoader ?? CachedImageLoader()
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: launchEnvironment.apiBaseURL ?? AppEnvironment.current.rickAndMorty.baseURL
        )
        let providers = Self.makeTrackingProviders()
        providers.forEach { $0.configure() }
        self.tracker = tracker ?? Tracker(providers: providers)

        homeFeature = HomeFeature(tracker: self.tracker)
        characterFeature = CharacterFeature(httpClient: self.httpClient, tracker: self.tracker)
        systemFeature = SystemFeature(tracker: self.tracker)
    }

    // MARK: - Navigation Resolution

    /// Resolves any navigation to a view by iterating through features.
    /// Falls back to NotFoundView if no feature can handle the navigation.
    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView {
        for feature in features {
            if let view = feature.resolve(navigation, navigator: navigator) {
                return view
            }
        }
        return systemFeature.makeMainView(navigator: navigator)
    }

    // MARK: - Deep Link Handling

    public func handle(url: URL, navigator: any NavigatorContract) {
        for feature in features {
            if let navigation = feature.deepLinkHandler?.resolve(url) {
                navigator.navigate(to: navigation)
                return
            }
        }
        navigator.navigate(to: UnknownNavigation.notFound)
    }

    // MARK: - Factory Methods

    public func makeRootView(navigator: any NavigatorContract) -> AnyView {
        homeFeature.makeMainView(navigator: navigator)
    }
}

// MARK: - Tracking Providers

private extension AppContainer {
    static func makeTrackingProviders() -> [any TrackingProviderContract] {
        [
            ConsoleTrackingProvider()
        ]
    }
}
```

**Rules:**
- Centralizes ALL dependency injection in one place
- Creates shared dependencies (HTTPClient, Tracker, ImageLoader)
- Injects shared dependencies into features or via SwiftUI environment
- Handles deep links via feature handlers
- `features` is a computed property aggregating private feature instances
- Tracking providers are registered via a static factory method (`makeTrackingProviders()`), as it is called during `init` before `self` is fully initialized

---

## FeatureContract Protocol (Core Module)

```swift
// Libraries/Core/Sources/Feature/Feature.swift
import SwiftUI

public protocol FeatureContract {
    var deepLinkHandler: (any DeepLinkHandlerContract)? { get }
    func makeMainView(navigator: any NavigatorContract) -> AnyView
    func resolve(_ navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView?
}

public extension FeatureContract {
    var deepLinkHandler: (any DeepLinkHandlerContract)? { nil }
}
```

---

## ChallengeApp (Minimal Entry Point)

```swift
// App/Sources/ChallengeApp.swift
import ChallengeAppKit
import SwiftUI

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

---

## RootContainerView

```swift
// AppKit/Sources/Presentation/Views/RootContainerView.swift
import ChallengeCore
import SwiftUI

public struct RootContainerView: View {
    public let appContainer: AppContainer

    @State private var navigationCoordinator = NavigationCoordinator(redirector: AppNavigationRedirect())

    public init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }

    public var body: some View {
        NavigationContainerView(navigationCoordinator: navigationCoordinator, appContainer: appContainer) {
            appContainer.makeRootView(navigator: navigationCoordinator)
        }
        .imageLoader(appContainer.imageLoader)
        .onOpenURL { url in
            appContainer.handle(url: url, navigator: navigationCoordinator)
        }
    }
}

/*
#Preview {
    RootContainerView(appContainer: AppContainer())
}
*/
```

**Key Points:**
- Located in `AppKit` module (not `App`) for testability without TEST_HOST
- Uses `NavigationContainerView` for NavigationStack + push destinations + modal bindings
- Injects `imageLoader` via SwiftUI environment for all descendant views (`DSAsyncImage`)
- Only adds `.onOpenURL` on top of `NavigationContainerView`
