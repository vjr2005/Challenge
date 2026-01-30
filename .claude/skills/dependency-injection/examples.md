# Dependency Injection Examples

Complete implementation examples for dependency injection with Composition Root pattern.

---

## AppContainer Example (Composition Root)

```swift
// App/Sources/AppContainer.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import ChallengeNetworking
import SwiftUI

struct AppContainer: Sendable {
    // MARK: - Shared Dependencies

    let httpClient: any HTTPClientContract

    // MARK: - Features

    let features: [any Feature]

    // MARK: - Init

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: AppEnvironment.current.rickAndMorty.baseURL
        )

        self.features = [
            CharacterFeature(httpClient: self.httpClient),
            HomeFeature()
        ]
    }

    func handle(url: URL, navigator: any NavigatorContract) {
        for feature in features {
            if let navigation = feature.deepLinkHandler?.resolve(url) {
                navigator.navigate(to: navigation)
                return
            }
        }
    }

    // MARK: - Factory Methods

    func makeRootView(navigator: any NavigatorContract) -> some View {
        HomeFeature().makeHomeView(navigator: navigator)
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
    func redirect(_ navigation: any Navigation) -> (any Navigation)? {
        switch navigation {
        case let outgoing as HomeOutgoingNavigation:
            return redirect(outgoing)
        default:
            return nil
        }
    }

    // MARK: - Private

    private func redirect(_ navigation: HomeOutgoingNavigation) -> any Navigation {
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

public final class CharacterContainer: Sendable {
    // MARK: - Dependencies

    private let httpClient: any HTTPClientContract
    private let memoryDataSource = CharacterMemoryDataSource()

    // MARK: - Init

    public init(httpClient: any HTTPClientContract) {
        self.httpClient = httpClient
    }

    // MARK: - Repository

    private var repository: any CharacterRepositoryContract {
        CharacterRepository(
            remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Factories

    func makeCharacterListViewModel(navigator: any NavigatorContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: repository),
            navigator: CharacterListNavigator(navigator: navigator)
        )
    }

    func makeCharacterDetailViewModel(
        identifier: Int,
        navigator: any NavigatorContract
    ) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: GetCharacterUseCase(repository: repository),
            navigator: CharacterDetailNavigator(navigator: navigator)
        )
    }
}
```

### Navigation Destinations

```swift
// Features/Character/Sources/Navigation/CharacterIncomingNavigation.swift
import ChallengeCore

public enum CharacterIncomingNavigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

### Feature (Public Entry Point)

```swift
// Features/Character/Sources/CharacterFeature.swift
import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct CharacterFeature: Feature {
    // MARK: - Dependencies

    private let container: CharacterContainer

    // MARK: - Init

    public init(httpClient: any HTTPClientContract) {
        self.container = CharacterContainer(httpClient: httpClient)
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: any DeepLinkHandler {
        CharacterDeepLinkHandler()
    }

    public func applyNavigationDestination<V: View>(to view: V, navigator: any NavigatorContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: CharacterIncomingNavigation.self) { navigation in
                self.view(for: navigation, navigator: navigator)
            }
        )
    }
}

// MARK: - Private

extension CharacterFeature {
    @ViewBuilder
    func view(for navigation: CharacterIncomingNavigation, navigator: any NavigatorContract) -> some View {
        switch navigation {
        case .list:
            CharacterListView(viewModel: container.makeCharacterListViewModel(navigator: navigator))
        case .detail(let identifier):
            CharacterDetailView(
                viewModel: container.makeCharacterDetailViewModel(
                    identifier: identifier,
                    navigator: navigator
                )
            )
        }
    }
}
```

### Usage from App

```swift
// App/Sources/ChallengeApp.swift
import SwiftUI

@main
struct ChallengeApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootContainerView(appContainer: container)
        }
    }
}
```

```swift
// App/Sources/Presentation/Views/RootContainerView.swift
import ChallengeCore
import ChallengeHome
import SwiftUI

struct RootContainerView: View {
    let appContainer: AppContainer
    @State private var coordinator = NavigationCoordinator(redirector: AppNavigationRedirect())

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            appContainer.makeRootView(navigator: coordinator)
                .withNavigationDestinations(features: appContainer.features, navigator: coordinator)
        }
        .onOpenURL { url in
            appContainer.handle(url: url, navigator: coordinator)
        }
    }
}

#Preview {
    RootContainerView(appContainer: AppContainer())
}
```

---

## HomeFeature Example (Simple)

### Container

```swift
// Features/Home/Sources/HomeContainer.swift
import ChallengeCore

public final class HomeContainer: Sendable {
    // MARK: - Init

    public init() {}

    // MARK: - Factories

    func makeHomeViewModel(navigator: any NavigatorContract) -> HomeViewModel {
        HomeViewModel(navigator: HomeNavigator(navigator: navigator))
    }
}
```

### Navigation

```swift
// Features/Home/Sources/Navigation/HomeIncomingNavigation.swift
import ChallengeCore

public enum HomeIncomingNavigation: Navigation {
    case main
}
```

```swift
// Features/Home/Sources/Navigation/HomeOutgoingNavigation.swift
import ChallengeCore

public enum HomeOutgoingNavigation: Navigation {
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

public struct HomeFeature: Feature {
    // MARK: - Dependencies

    private let container: HomeContainer

    // MARK: - Init

    public init() {
        self.container = HomeContainer()
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: any DeepLinkHandler {
        HomeDeepLinkHandler()
    }

    public func applyNavigationDestination<V: View>(to view: V, navigator: any NavigatorContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: HomeIncomingNavigation.self) { navigation in
                self.view(for: navigation, navigator: navigator)
            }
        )
    }

    // MARK: - Factory

    public func makeHomeView(navigator: any NavigatorContract) -> some View {
        HomeView(viewModel: container.makeHomeViewModel(navigator: navigator))
    }
}

extension HomeFeature {
    @ViewBuilder
    func view(for navigation: HomeIncomingNavigation, navigator: any NavigatorContract) -> some View {
        switch navigation {
        case .main:
            HomeView(viewModel: container.makeHomeViewModel(navigator: navigator))
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
    // MARK: - Init

    @Test
    func initWithHTTPClientDoesNotCrash() {
        // Given
        let httpClientMock = HTTPClientMock()

        // When
        let sut = CharacterFeature(httpClient: httpClientMock)

        // Then - Feature initializes without crashing
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test
    func applyNavigationDestinationReturnsView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)
        let baseView = EmptyView()

        // When
        let result = sut.applyNavigationDestination(to: baseView, navigator: navigatorMock)

        // Then - Method completes without crashing and returns a view
        _ = result
    }

    // MARK: - View Factory

    @Test
    func viewForListNavigationReturnsCharacterListView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.view(for: .list, navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("CharacterListView"))
    }

    @Test
    func viewForDetailNavigationReturnsCharacterDetailView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.view(for: .detail(identifier: 42), navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("CharacterDetailView"))
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
    // MARK: - Init

    @Test
    func initDoesNotCrash() {
        // When
        let sut = HomeFeature()

        // Then
        _ = sut
    }

    // MARK: - Factory

    @Test
    func makeHomeViewReturnsConfiguredInstance() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()

        // When
        let view = sut.makeHomeView(navigator: navigatorMock)

        // Then
        _ = view
    }

    // MARK: - Navigation Destination

    @Test
    func applyNavigationDestinationReturnsView() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()
        let baseView = EmptyView()

        // When
        let result = sut.applyNavigationDestination(to: baseView, navigator: navigatorMock)

        // Then
        _ = result
    }

    // MARK: - View Factory

    @Test
    func viewForMainNavigationReturnsHomeView() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()

        // When
        let result = sut.view(for: .main, navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("HomeView"))
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
    // MARK: - Init

    @Test
    func initWithHTTPClientDoesNotCrash() {
        // Given
        let httpClientMock = HTTPClientMock()

        // When
        let sut = {Feature}Feature(httpClient: httpClientMock)

        // Then
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test
    func applyNavigationDestinationReturnsView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = {Feature}Feature(httpClient: httpClientMock)
        let baseView = EmptyView()

        // When
        let result = sut.applyNavigationDestination(to: baseView, navigator: navigatorMock)

        // Then
        _ = result
    }

    // MARK: - View Factory

    @Test
    func viewForListNavigationReturnsListView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = {Feature}Feature(httpClient: httpClientMock)

        // When
        let result = sut.view(for: .list, navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("{Name}ListView"))
    }
}
```

### What to Test

| Test | Purpose |
|------|---------|
| Init with HTTPClient | Verify feature initializes without crashing |
| applyNavigationDestination | Verify navigation destinations are registered |
| view(for:navigator:) | Verify correct view is returned for each navigation case |

**Note:** Factory methods are internal to Container. Test them indirectly through ViewModel tests, Repository tests, and DeepLinkHandler tests.
