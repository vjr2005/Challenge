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
import ChallengeShared

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

        features.forEach { $0.registerDeepLinks() }
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

    func makeCharacterListViewModel(router: any RouterContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: repository),
            navigator: CharacterListNavigator(router: router)
        )
    }

    func makeCharacterDetailViewModel(
        identifier: Int,
        router: any RouterContract
    ) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: GetCharacterUseCase(repository: repository),
            navigator: CharacterDetailNavigator(router: router)
        )
    }
}
```

### Navigation Destinations

```swift
// Features/Character/Sources/Navigation/CharacterNavigation.swift
import ChallengeCore

public enum CharacterNavigation: Navigation {
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

    public func registerDeepLinks() {
        CharacterDeepLinkHandler.register()
    }

    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: CharacterNavigation.self) { navigation in
                self.view(for: navigation, router: router)
            }
        )
    }
}

// MARK: - Private

private extension CharacterFeature {
    @ViewBuilder
    func view(for navigation: CharacterNavigation, router: any RouterContract) -> some View {
        switch navigation {
        case .list:
            CharacterListView(viewModel: container.makeCharacterListViewModel(router: router))
        case .detail(let identifier):
            CharacterDetailView(
                viewModel: container.makeCharacterDetailViewModel(
                    identifier: identifier,
                    router: router
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
            RootView(features: container.features)
        }
    }
}
```

```swift
// App/Sources/RootView.swift
import ChallengeCore
import ChallengeHome
import SwiftUI

struct RootView: View {
    let features: [any Feature]
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeFeature()
                .makeHomeView(router: router)
                .withNavigationDestinations(features: features, router: router)
        }
        .onOpenURL { url in
            router.navigate(to: url)
        }
    }
}

#Preview {
    RootView(features: AppContainer().features)
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

    func makeHomeViewModel(router: any RouterContract) -> HomeViewModel {
        HomeViewModel(navigator: HomeNavigator(router: router))
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

    public func registerDeepLinks() {
        // Home has no deep links
    }

    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(view)
    }

    // MARK: - Factory

    public func makeHomeView(router: any RouterContract) -> some View {
        HomeView(viewModel: container.makeHomeViewModel(router: router))
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
    func registerDeepLinksRegistersCharacterHandler() throws {
        // Given
        let httpClientMock = HTTPClientMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        sut.registerDeepLinks()

        // Then - Deep link is registered (verify by resolving a known URL)
        let url = try #require(URL(string: "challenge://character/list"))
        let navigation = DeepLinkRegistry.shared.resolve(url)
        #expect(navigation != nil)
    }

    @Test
    func registerDeepLinksRegistersDetailPath() throws {
        // Given
        let httpClientMock = HTTPClientMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        sut.registerDeepLinks()

        // Then
        let url = try #require(URL(string: "challenge://character/detail?id=42"))
        let navigation = DeepLinkRegistry.shared.resolve(url)
        #expect(navigation != nil)
    }
}
```

### HomeFeatureTests (Simple Feature)

```swift
import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeFeatureTests {
    @Test
    func initDoesNotCrash() {
        // Given/When
        let sut = HomeFeature()

        // Then
        _ = sut
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
    func registerDeepLinksRegistersHandler() throws {
        // Given
        let httpClientMock = HTTPClientMock()
        let sut = {Feature}Feature(httpClient: httpClientMock)

        // When
        sut.registerDeepLinks()

        // Then - Deep link is registered
        let url = try #require(URL(string: "challenge://{feature}/list"))
        let navigation = DeepLinkRegistry.shared.resolve(url)
        #expect(navigation != nil)
    }
}
```

### What to Test

| Test | Purpose |
|------|---------|
| Init with HTTPClient | Verify feature initializes without crashing |
| registerDeepLinks() | Verify deep links are registered correctly |

**Note:** Factory methods are internal to Container. Test them indirectly through ViewModel tests, Repository tests, and DeepLinkHandler tests.
