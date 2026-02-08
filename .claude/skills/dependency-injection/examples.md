# Dependency Injection Examples

Complete implementation examples for dependency injection with Composition Root pattern.

---

## AppContainer Example (Composition Root)

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
        httpClient: (any HTTPClientContract)? = nil,
        tracker: (any TrackerContract)? = nil,
        imageLoader: (any ImageLoaderContract)? = nil
    ) {
        self.imageLoader = imageLoader ?? CachedImageLoader()
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: AppEnvironment.current.rickAndMorty.baseURL
        )
        self.tracker = tracker ?? Tracker(providers: Self.makeTrackingProviders())

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
        // Fallback to SystemFeature's main view (NotFoundView)
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

---

## AppNavigationRedirect Example

```swift
// App/Sources/Navigation/AppNavigationRedirect.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeHome

struct AppNavigationRedirect: NavigationRedirectContract {
    func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)? {
        switch navigation {
        case let outgoing as HomeOutgoingNavigation:
            return redirect(outgoing)
        default:
            return nil
        }
    }

    // MARK: - Private

    private func redirect(_ navigation: HomeOutgoingNavigation) -> any NavigationContract {
        switch navigation {
        case .characters:
            return CharacterIncomingNavigation.list
        }
    }
}
```

---

## CharacterFeature Example

### Container (Dependency Composition)

```swift
// Features/Character/Sources/CharacterContainer.swift
import ChallengeCore
import ChallengeNetworking

public final class CharacterContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Repositories

    private let characterRepository: any CharacterRepositoryContract
    private let recentSearchesRepository: any RecentSearchesRepositoryContract
    private let charactersPageRepository: any CharactersPageRepositoryContract

    // MARK: - Init

    public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.tracker = tracker
        let remoteDataSource = CharacterRemoteDataSource(httpClient: httpClient)
        let memoryDataSource = CharacterMemoryDataSource()
        let recentSearchesDataSource = RecentSearchesLocalDataSource()
        self.characterRepository = CharacterRepository(
            remoteDataSource: remoteDataSource,
            memoryDataSource: memoryDataSource
        )
        self.recentSearchesRepository = RecentSearchesRepository(
            localDataSource: recentSearchesDataSource
        )
        self.charactersPageRepository = CharactersPageRepository(
            remoteDataSource: remoteDataSource,
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Factories

    func makeCharacterListViewModel(navigator: any NavigatorContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersPageUseCase: GetCharactersPageUseCase(repository: charactersPageRepository),
            refreshCharactersPageUseCase: RefreshCharactersPageUseCase(repository: charactersPageRepository),
            searchCharactersPageUseCase: SearchCharactersPageUseCase(repository: charactersPageRepository),
            getRecentSearchesUseCase: GetRecentSearchesUseCase(repository: recentSearchesRepository),
            saveRecentSearchUseCase: SaveRecentSearchUseCase(repository: recentSearchesRepository),
            deleteRecentSearchUseCase: DeleteRecentSearchUseCase(repository: recentSearchesRepository),
            navigator: CharacterListNavigator(navigator: navigator),
            tracker: CharacterListTracker(tracker: tracker)
        )
    }

    func makeCharacterDetailViewModel(
        identifier: Int,
        navigator: any NavigatorContract
    ) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: GetCharacterUseCase(repository: characterRepository),
            refreshCharacterUseCase: RefreshCharacterUseCase(repository: characterRepository),
            navigator: CharacterDetailNavigator(navigator: navigator),
            tracker: CharacterDetailTracker(tracker: tracker)
        )
    }

    func makeAdvancedSearchViewModel(
        delegate: any CharacterFilterDelegate,
        navigator: any NavigatorContract
    ) -> AdvancedSearchViewModel {
        AdvancedSearchViewModel(
            delegate: delegate,
            navigator: AdvancedSearchNavigator(navigator: navigator),
            tracker: AdvancedSearchTracker(tracker: tracker)
        )
    }
}
```

**Key patterns:**
- Use singular names for single-item UseCases: `GetCharacterUseCase`
- Inject **separate Get and Refresh UseCases**
- Get UseCases use `localFirst` cache policy (fast initial load)
- Refresh UseCases use `remoteFirst` cache policy (pull-to-refresh)
- Only store what factory methods need after `init` (`tracker`, repositories)
- DataSources are **local variables in `init`** — only needed to build repositories
- Inter-ViewModel communication uses **delegate pattern** through navigation enum (e.g., `CharacterFilterDelegate`)

### Navigation Destinations

```swift
// Features/Character/Sources/Navigation/CharacterIncomingNavigation.swift
import ChallengeCore

public enum CharacterIncomingNavigation: IncomingNavigationContract {
    case list
    case detail(identifier: Int)
    case advancedSearch(delegate: any CharacterFilterDelegate)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.list, .list):
            return true
        case (.detail(let lhsID), .detail(let rhsID)):
            return lhsID == rhsID
        case (.advancedSearch, .advancedSearch):
            return true
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .list:
            hasher.combine(0)
        case .detail(let identifier):
            hasher.combine(1)
            hasher.combine(identifier)
        case .advancedSearch:
            hasher.combine(2)
        }
    }
}
```

When an `IncomingNavigation` case carries a non-Hashable associated value (e.g., a delegate), implement custom `Equatable` and `Hashable` that ignore the delegate identity.

### Feature (Public Entry Point)

```swift
// Features/Character/Sources/CharacterFeature.swift
import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct CharacterFeature: FeatureContract {
    // MARK: - Dependencies

    private let container: CharacterContainer

    // MARK: - Init

    public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.container = CharacterContainer(httpClient: httpClient, tracker: tracker)
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        CharacterDeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(CharacterListView(
            viewModel: container.makeCharacterListViewModel(navigator: navigator)
        ))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? CharacterIncomingNavigation else {
            return nil
        }
        switch navigation {
        case .list:
            return makeMainView(navigator: navigator)
        case .detail(let identifier):
            return AnyView(CharacterDetailView(
                viewModel: container.makeCharacterDetailViewModel(
                    identifier: identifier,
                    navigator: navigator
                )
            ))
        case .advancedSearch(let delegate):
            return AnyView(AdvancedSearchView(
                viewModel: container.makeAdvancedSearchViewModel(
                    delegate: delegate,
                    navigator: navigator
                )
            ))
        }
    }
}
```

### Usage from App

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

```swift
// AppKit/Sources/Presentation/Views/RootContainerView.swift
import ChallengeCore
import SwiftUI

public struct RootContainerView: View {
    public let appContainer: AppContainer

    @State private var navigationCoordinator: NavigationCoordinator

    public init(appContainer: AppContainer) {
        self.appContainer = appContainer
        _navigationCoordinator = State(initialValue: NavigationCoordinator(redirector: AppNavigationRedirect()))
    }

    public var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            appContainer.makeRootView(navigator: navigationCoordinator)
                .navigationDestination(for: AnyNavigation.self) { navigation in
                    appContainer.resolve(navigation.wrapped, navigator: navigationCoordinator)
                }
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

---

## HomeFeature Example (Simple)

### Container

```swift
// Features/Home/Sources/HomeContainer.swift
import ChallengeCore

public final class HomeContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Init

    public init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    // MARK: - Factories

    func makeHomeViewModel(navigator: any NavigatorContract) -> HomeViewModel {
        HomeViewModel(
            navigator: HomeNavigator(navigator: navigator),
            tracker: HomeTracker(tracker: tracker)
        )
    }
}
```

### Navigation

```swift
// Features/Home/Sources/Navigation/HomeIncomingNavigation.swift
import ChallengeCore

public enum HomeIncomingNavigation: IncomingNavigationContract {
    case main
}
```

```swift
// Features/Home/Sources/Navigation/HomeOutgoingNavigation.swift
import ChallengeCore

public enum HomeOutgoingNavigation: OutgoingNavigationContract {
    case characters
}
```

### Navigator

```swift
// Features/Home/Sources/Presentation/Home/Navigator/HomeNavigator.swift
import ChallengeCore

struct HomeNavigator: HomeNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToCharacters() {
        navigator.navigate(to: HomeOutgoingNavigation.characters)
    }
}
```

### Feature (Public Entry Point)

```swift
// Features/Home/Sources/HomeFeature.swift
import ChallengeCore
import SwiftUI

public struct HomeFeature: FeatureContract {
    // MARK: - Dependencies

    private let container: HomeContainer

    // MARK: - Init

    public init(tracker: any TrackerContract) {
        self.container = HomeContainer(tracker: tracker)
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        HomeDeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(HomeView(viewModel: container.makeHomeViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? HomeIncomingNavigation else {
            return nil
        }
        switch navigation {
        case .main:
            return makeMainView(navigator: navigator)
        }
    }
}
```

---

## Feature Tests

Features are tested through their **public interface**. Factory methods are internal to Container.

### CharacterFeatureTests

```swift
import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import SwiftUI
import Testing

@testable import ChallengeCharacter

struct CharacterFeatureTests {
    // MARK: - Properties

    private let httpClientMock = HTTPClientMock()
    private let trackerMock = TrackerMock()
    private let navigatorMock = NavigatorMock()
    private let sut: CharacterFeature

    // MARK: - Initialization

    init() {
        sut = CharacterFeature(httpClient: httpClientMock, tracker: trackerMock)
    }

    // MARK: - Init

    @Test("Init with HTTP client does not crash")
    func initWithHTTPClientDoesNotCrash() {
        // Then - Feature initializes without crashing
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test("Make main view returns character list view")
    func makeMainViewReturnsCharacterListView() {
        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        _ = result
    }

    @Test("Resolve list navigation returns view")
    func resolveListNavigationReturnsView() {
        // When
        let result = sut.resolve(CharacterIncomingNavigation.list, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test("Resolve detail navigation returns view")
    func resolveDetailNavigationReturnsView() {
        // When
        let result = sut.resolve(CharacterIncomingNavigation.detail(identifier: 42), navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test("Resolve advanced search navigation returns view")
    func resolveAdvancedSearchNavigationReturnsView() {
        // Given
        let delegateMock = CharacterFilterDelegateMock()

        // When
        let result = sut.resolve(
            CharacterIncomingNavigation.advancedSearch(delegate: delegateMock),
            navigator: navigatorMock
        )

        // Then
        #expect(result != nil)
    }

    @Test("Resolve unknown navigation returns nil")
    func resolveUnknownNavigationReturnsNil() {
        // Given
        struct UnknownNavigation: NavigationContract {}

        // When
        let result = sut.resolve(UnknownNavigation(), navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}
```

### HomeFeatureTests (Simple Feature)

```swift
import ChallengeCore
import ChallengeCoreMocks
import SwiftUI
import Testing

@testable import ChallengeHome

struct HomeFeatureTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let navigatorMock = NavigatorMock()
    private let sut: HomeFeature

    // MARK: - Initialization

    init() {
        sut = HomeFeature(tracker: trackerMock)
    }

    // MARK: - Init

    @Test
    func initDoesNotCrash() {
        // Then
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test
    func makeMainViewReturnsHomeView() {
        // When
        let view = sut.makeMainView(navigator: navigatorMock)

        // Then
        _ = view
    }

    @Test
    func resolveMainNavigationReturnsView() {
        // When
        let result = sut.resolve(HomeIncomingNavigation.main, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test
    func resolveUnknownNavigationReturnsNil() {
        // Given
        struct UnknownNavigation: NavigationContract {}

        // When
        let result = sut.resolve(UnknownNavigation(), navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}
```

---

## Generic Feature Tests Pattern

```swift
import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import SwiftUI
import Testing

@testable import Challenge{Feature}

struct {Feature}FeatureTests {
    // MARK: - Properties

    private let httpClientMock = HTTPClientMock()
    private let trackerMock = TrackerMock()
    private let navigatorMock = NavigatorMock()
    private let sut: {Feature}Feature

    // MARK: - Initialization

    init() {
        sut = {Feature}Feature(httpClient: httpClientMock, tracker: trackerMock)
    }

    // MARK: - Init

    @Test
    func initWithHTTPClientDoesNotCrash() {
        // Then
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test
    func makeMainViewReturnsView() {
        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        _ = result
    }

    @Test
    func resolveListNavigationReturnsView() {
        // When
        let result = sut.resolve({Feature}IncomingNavigation.list, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test
    func resolveUnknownNavigationReturnsNil() {
        // Given
        struct UnknownNavigation: NavigationContract {}

        // When
        let result = sut.resolve(UnknownNavigation(), navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}
```

### What to Test

| Test | Purpose |
|------|---------|
| Init with HTTPClient | Verify feature initializes without crashing |
| makeMainView() | Verify default entry point view is created |
| resolve() with valid navigation | Verify correct view is returned for each navigation case |
| resolve() with unknown navigation | Verify nil is returned for unhandled navigation |

**Note:** Factory methods are internal to Container. Test them indirectly through ViewModel tests, Repository tests, and DeepLinkHandler tests.
