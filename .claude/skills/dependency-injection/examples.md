# Dependency Injection Examples

Complete implementation examples for dependency injection with Feature per Module pattern.

---

## CharacterFeature Example

### Navigation Destinations

```swift
// Sources/Navigation/CharacterNavigation.swift
import {AppName}Core

public enum CharacterNavigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

### Public Entry Point (Feature Struct)

```swift
// Sources/CharacterFeature.swift
import {AppName}Common
import {AppName}Core
import {AppName}Networking
import SwiftUI

public struct CharacterFeature: Feature {
    // MARK: - Dependencies

    private let httpClient: any HTTPClientContract
    private let memoryDataSource = CharacterMemoryDataSource()

    private var repository: any CharacterRepositoryContract {
        CharacterRepository(
            remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Init

    public init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(baseURL: AppEnvironment.current.rickAndMorty.baseURL)
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
    // MARK: - Views

    @ViewBuilder
    func view(for navigation: CharacterNavigation, router: any RouterContract) -> some View {
        switch navigation {
        case .list:
            CharacterListView(viewModel: makeCharacterListViewModel(router: router))
        case .detail(let identifier):
            CharacterDetailView(viewModel: makeCharacterDetailViewModel(identifier: identifier, router: router))
        }
    }

    // MARK: - Factories

    func makeCharacterListViewModel(router: any RouterContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: repository),
            navigator: CharacterListNavigator(router: router)
        )
    }

    func makeCharacterDetailViewModel(identifier: Int, router: any RouterContract) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: GetCharacterUseCase(repository: repository),
            navigator: CharacterDetailNavigator(router: router)
        )
    }
}
```

### Usage from App

```swift
// In App/Sources/ChallengeApp.swift
import {AppName}Character
import {AppName}Core
import {AppName}Home
import SwiftUI

@main
struct ChallengeApp: App {
    let features: [any Feature] = [
        CharacterFeature(),
        HomeFeature()
    ]

    init() {
        features.forEach { $0.registerDeepLinks() }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(features: features)
        }
    }
}
```

```swift
// In App/Sources/ContentView.swift
import {AppName}Character
import {AppName}Core
import {AppName}Home
import SwiftUI

struct ContentView: View {
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
    ContentView(features: [CharacterFeature(), HomeFeature()])
}
```

---

## HomeFeature Example (Simple)

### Public Entry Point

```swift
// Sources/HomeFeature.swift
import {AppName}Core
import SwiftUI

public struct HomeFeature: Feature {
    public init() {}

    // MARK: - Feature Protocol

    public func registerDeepLinks() {
        // Home has no deep links
    }

    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(view)
    }

    // MARK: - Factory

    public func makeHomeView(router: any RouterContract) -> some View {
        HomeView(viewModel: HomeViewModel(navigator: HomeNavigator(router: router)))
    }
}
```

---

## Feature Tests

Features are tested through their **public interface**. Factory methods are private implementation details.

### CharacterFeatureTests

```swift
import {AppName}Core
import {AppName}CoreMocks
import {AppName}NetworkingMocks
import Foundation
import Testing

@testable import {AppName}Character

struct CharacterFeatureTests {
    // MARK: - Init

    @Test
    func initWithDefaultHTTPClientDoesNotCrash() {
        // Given/When
        let sut = CharacterFeature()

        // Then - Feature initializes without crashing
        _ = sut
    }

    @Test
    func initWithCustomHTTPClientDoesNotCrash() {
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
        let sut = CharacterFeature()

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
        let sut = CharacterFeature()

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
import {AppName}CoreMocks
import Testing

@testable import {AppName}Home

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
import {AppName}Core
import {AppName}CoreMocks
import {AppName}NetworkingMocks
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Feature}FeatureTests {
    // MARK: - Init

    @Test
    func initWithDefaultDependenciesDoesNotCrash() {
        // Given/When
        let sut = {Feature}Feature()

        // Then
        _ = sut
    }

    @Test
    func initWithCustomDependenciesDoesNotCrash() {
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
        let sut = {Feature}Feature()

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
| Init with default dependencies | Verify feature initializes without crashing |
| Init with custom dependencies | Verify dependency injection works |
| registerDeepLinks() | Verify deep links are registered correctly |

**Note:** Factory methods are private. Test them indirectly through ViewModel tests, Repository tests, and DeepLinkHandler tests.
