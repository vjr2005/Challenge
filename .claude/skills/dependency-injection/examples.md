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

    @MainActor
    public func registerDeepLinks() {
        CharacterDeepLinkHandler.register()
    }

    @MainActor
    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: CharacterNavigation.self) { navigation in
                self.view(for: navigation, router: router)
            }
        )
    }

    // MARK: - Views

    @MainActor
    @ViewBuilder
    private func view(for navigation: CharacterNavigation, router: any RouterContract) -> some View {
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
    static let features: [any Feature] = [
        CharacterFeature(),
        HomeFeature()
    ]

    init() {
        Self.features.forEach { $0.registerDeepLinks() }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(features: Self.features)
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

    @MainActor
    public func registerDeepLinks() {
        // Home has no deep links
    }

    @MainActor
    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(view)
    }

    // MARK: - Factory

    @MainActor
    public func makeHomeView(router: any RouterContract) -> some View {
        HomeView(viewModel: HomeViewModel(navigator: HomeNavigator(router: router)))
    }
}
```

---

## Feature Tests

### CharacterFeatureTests

```swift
import {AppName}CoreMocks
import {AppName}NetworkingMocks
import Foundation
import Testing

@testable import {AppName}Character

struct CharacterFeatureTests {
    private let testBundle = Bundle(for: BundleToken.self)

    // MARK: - CharacterListViewModel

    @Test
    func makeCharacterListViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeCharacterListViewModel(router: routerMock)

        // Then
        #expect(viewModel.state == .idle)
    }

    @Test
    func makeCharacterListViewModelUsesInjectedHTTPClient() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("characters_response")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)
        let viewModel = sut.makeCharacterListViewModel(router: routerMock)

        // When
        await viewModel.load()

        // Then
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }

    // MARK: - CharacterDetailViewModel

    @Test
    func makeCharacterDetailViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)

        // Then
        #expect(viewModel.state == .idle)
    }

    @Test
    func makeCharacterDetailViewModelUsesInjectedHTTPClient() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("character")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)

        // When
        await viewModel.load()

        // Then
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }

    // MARK: - Shared Repository

    @Test
    func multipleDetailViewModelsShareSameRepository() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("character")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let viewModel1 = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)
        let viewModel2 = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)

        await viewModel1.load()
        await viewModel2.load()

        // Then - Second load uses cached data from shared repository
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }

    @Test
    func listAndDetailViewModelsShareSameRepository() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("characters_response")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When - Load characters via list, then get one character via detail
        let listViewModel = sut.makeCharacterListViewModel(router: routerMock)
        await listViewModel.load()

        let detailViewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)
        await detailViewModel.load()

        // Then - Detail should use cached character from list response (only 1 HTTP call total)
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }
}

private final class BundleToken {}
```

### HomeFeatureTests (Simple Feature)

```swift
import {AppName}CoreMocks
import Testing

@testable import {AppName}Home

struct HomeFeatureTests {
    @Test
    func makeHomeViewReturnsConfiguredInstance() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeFeature()

        // When
        let view = sut.makeHomeView(router: routerMock)

        // Then - Verify factory returns a properly configured instance
        // HomeView is stateless, so we just verify it was created
        _ = view
    }
}
```

---

## Generic Feature Tests Pattern

```swift
import {AppName}CoreMocks
import {AppName}NetworkingMocks
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Feature}FeatureTests {
    private let testBundle = Bundle(for: BundleToken.self)

    @Test
    func makeViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = {Feature}Feature(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeDetailViewModel(identifier: 42, router: routerMock)

        // Then
        #expect(viewModel.state == .idle)
    }

    @Test
    func makeViewModelUsesSharedRepository() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("{name}")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let routerMock = RouterMock()
        let sut = {Feature}Feature(httpClient: httpClientMock)

        // When
        let viewModel1 = sut.makeDetailViewModel(identifier: 1, router: routerMock)
        let viewModel2 = sut.makeDetailViewModel(identifier: 1, router: routerMock)

        // Load data through both ViewModels
        await viewModel1.load()
        await viewModel2.load()

        // Then - Both should use the same repository (second call uses cache)
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }
}

private final class BundleToken {}
```

### What to Test

| Test | Purpose |
|------|---------|
| Factory returns instance | Verify wiring doesn't crash |
| Shared repository | Verify memoryDataSource is reused across ViewModels |
| Injected dependencies | Verify mock is used when injected |
