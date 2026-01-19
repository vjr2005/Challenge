# Dependency Injection Examples

Complete implementation examples for dependency injection with Container per Feature pattern.

---

## CharacterFeature Example

### Navigation Destinations

```swift
// Sources/CharacterNavigation.swift
import ChallengeCore

public enum CharacterNavigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

### Public Entry Point

```swift
// Sources/CharacterFeature.swift
import ChallengeCore
import SwiftUI

public enum CharacterFeature {
    private static let container = CharacterContainer()

    @ViewBuilder
    public static func view(for navigation: CharacterNavigation, router: RouterContract) -> some View {
        switch navigation {
        case .list:
            CharacterListView(viewModel: container.makeListViewModel(router: router))
        case .detail(let identifier):
            CharacterDetailView(viewModel: container.makeDetailViewModel(identifier: identifier, router: router))
        }
    }
}
```

### Internal Container

```swift
// Sources/Container/CharacterContainer.swift
import ChallengeCore
import ChallengeNetworking
import Foundation

final class CharacterContainer {
    // MARK: - Infrastructure

    private let httpClient: any HTTPClientContract

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(baseURL: APIConfiguration.rickAndMorty.baseURL)
    }

    // MARK: - Shared (lazy) - Source of Truth

    private let memoryDataSource = CharacterMemoryDataSource()

    private lazy var repository: any CharacterRepositoryContract = CharacterRepository(
        remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    // MARK: - Factories

    func makeListViewModel(router: RouterContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: makeGetCharactersUseCase(),
            router: router
        )
    }

    func makeDetailViewModel(identifier: Int, router: RouterContract) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: makeGetCharacterUseCase(),
            router: router
        )
    }

    private func makeGetCharactersUseCase() -> some GetCharactersUseCaseContract {
        GetCharactersUseCase(repository: repository)
    }

    private func makeGetCharacterUseCase() -> some GetCharacterUseCaseContract {
        GetCharacterUseCase(repository: repository)
    }
}
```

### Usage from App

```swift
// In App/Sources/ContentView.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import SwiftUI

struct ContentView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeFeature.makeHomeView(router: router)
                .navigationDestination(for: CharacterNavigation.self) { navigation in
                    CharacterFeature.view(for: navigation, router: router)
                }
        }
    }
}
```

---

## HomeFeature Example (Simple)

### Navigation Destinations

```swift
// Sources/HomeNavigation.swift
import ChallengeCore

public enum HomeNavigation: Navigation {
    case home
}
```

### Public Entry Point

```swift
// Sources/HomeFeature.swift
import ChallengeCore
import SwiftUI

public enum HomeFeature {
    private static let container = HomeContainer()

    @ViewBuilder
    public static func makeHomeView(router: RouterContract) -> some View {
        HomeView(viewModel: container.makeHomeViewModel(router: router))
    }
}
```

### Internal Container

```swift
// Sources/Container/HomeContainer.swift
import ChallengeCore

final class HomeContainer {
    func makeHomeViewModel(router: RouterContract) -> HomeViewModel {
        HomeViewModel(router: router)
    }
}
```

---

## Container Tests

### CharacterContainerTests

```swift
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeCharacter

struct CharacterContainerTests {
    @Test
    func makeCharacterDetailViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = CharacterContainer(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)

        // Then
        #expect(viewModel.state == .idle)
    }

    @Test
    func makeCharacterDetailViewModelUsesInjectedHTTPClient() async {
        // Given
        let httpClientMock = HTTPClientMock(result: .success(CharacterDTO.stubJSONData()))
        let routerMock = RouterMock()
        let sut = CharacterContainer(httpClient: httpClientMock)
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)

        // When
        await viewModel.load()

        // Then
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }

    @Test
    func multipleDetailViewModelsShareSameRepository() async {
        // Given
        let httpClientMock = HTTPClientMock(result: .success(CharacterDTO.stubJSONData()))
        let routerMock = RouterMock()
        let sut = CharacterContainer(httpClient: httpClientMock)

        // When
        let viewModel1 = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)
        let viewModel2 = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)

        await viewModel1.load()
        await viewModel2.load()

        // Then - Second load uses cached data from shared repository
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }
}
```

### HomeContainerTests (Simple Container)

```swift
import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeContainerTests {
    @Test
    func makeHomeViewModelReturnsConfiguredInstance() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeContainer()

        // When
        let viewModel = sut.makeHomeViewModel(router: routerMock)

        // Then - Verify factory returns a properly configured instance
        // HomeViewModel is stateless, so we just verify it was created
        _ = viewModel
    }
}
```

---

## Generic Container Tests Pattern

```swift
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import Challenge{Feature}

struct {Feature}ContainerTests {
    @Test
    func makeViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = {Feature}Container(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeDetailViewModel(identifier: 42, router: routerMock)

        // Then
        #expect(viewModel != nil)
    }

    @Test
    func makeViewModelUsesSharedRepository() async {
        // Given
        let httpClientMock = HTTPClientMock(result: .success({Name}DTO.stubJSONData()))
        let routerMock = RouterMock()
        let sut = {Feature}Container(httpClient: httpClientMock)

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
```

### What to Test

| Test | Purpose |
|------|---------|
| Factory returns instance | Verify wiring doesn't crash |
| Shared repository | Verify lazy var is reused across ViewModels |
| Injected dependencies | Verify mock is used when injected |
