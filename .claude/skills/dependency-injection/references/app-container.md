# AppContainer (Composition Root)

## AppContainer

```swift
// AppKit/Sources/AppContainer.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeEpisode
import ChallengeHome
import ChallengeNetworking
import ChallengeSystem
import SwiftUI

public struct AppContainer {
    // MARK: - Shared Dependencies

    private let launchEnvironment: LaunchEnvironment
    private let httpClient: any HTTPClientContract
    private let tracker: any TrackerContract
    let imageLoader: any ImageLoaderContract

    // MARK: - Features

    private let homeFeature: HomeFeature
    private let characterFeature: CharacterFeature
    private let episodeFeature: EpisodeFeature
    private let systemFeature: SystemFeature

    private var features: [any FeatureContract] {
        [homeFeature, characterFeature, episodeFeature, systemFeature]
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
        self.tracker = tracker ?? Self.makeTracker()

        homeFeature = HomeFeature(tracker: self.tracker)
        characterFeature = CharacterFeature(httpClient: self.httpClient, tracker: self.tracker)
        episodeFeature = EpisodeFeature(httpClient: self.httpClient, tracker: self.tracker)
        systemFeature = SystemFeature(tracker: self.tracker)
    }

    // MARK: - Navigation Resolution

    func resolveView(
        for navigation: any NavigationContract,
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

    func handle(url: URL, navigator: any NavigatorContract) {
        navigator.navigate(to: navigation(from: url))
    }

    // MARK: - Factory Methods

    func makeRootView(navigator: any NavigatorContract) -> AnyView {
        if let url = launchEnvironment.deepLinkURL {
            resolveView(forDeepLink: url, navigator: navigator)
        } else {
            homeFeature.makeMainView(navigator: navigator)
        }
    }
}

// MARK: - Navigation Resolution

private extension AppContainer {
    func resolveView(forDeepLink url: URL, navigator: any NavigatorContract) -> AnyView {
        resolveView(for: navigation(from: url), navigator: navigator)
    }

    func navigation(from url: URL) -> any NavigationContract {
        for feature in features {
            guard let handler = feature.deepLinkHandler,
                  url.scheme == handler.scheme,
                  url.host == handler.host,
                  let navigation = handler.resolve(url) else {
                continue
            }
            return navigation
        }
        return UnknownNavigation.notFound
    }
}

// MARK: - Tracking

private extension AppContainer {
    static func makeTracker() -> Tracker {
        let providers: [any TrackingProviderContract] = [
            ConsoleTrackingProvider()
        ]
        providers.forEach { $0.configure() }
        return Tracker(providers: providers)
    }
}
```

**Rules:**
- Only `public init` — everything else is `internal` or `private`
- `imageLoader` is `internal` (accessed by `RootContainerView` in same module)
- `resolveView(for:navigator:)` is `internal` (used by `NavigationContainerView` and `ModalContainerView`)
- `handle`, `makeRootView` are `internal` (used by `RootContainerView`)
- Deep link resolution and URL→Navigation mapping are `private`
- `makeRootView` returns the deep link view as root when `deepLinkURL` is set (no push through Home)
- Tracker creation is extracted to `makeTracker()` factory for clean init symmetry

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
- `makeRootView` handles deep link as root view — no `.onFirstAppear` needed
- `.onOpenURL` handles runtime deep links (push navigation)
