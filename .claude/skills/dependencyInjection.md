---
name: dependency-injection
autoContext: true
description: Creates Containers for dependency injection. Use when creating feature containers, exposing public entry points, or wiring up dependencies.
---

# Skill: Dependency Injection

Guide for creating dependency injection with Container per Feature pattern.

## When to use this skill

- Create a Container for a feature
- Expose a public entry point for the feature
- Wire up dependencies with lazy properties for stateful objects

## File structure

```
Libraries/Features/{FeatureName}/
├── Sources/
│   ├── {Feature}Feature.swift              # Public entry point (enum with view builder)
│   ├── {Feature}Navigation.swift           # Public navigation destinations
│   ├── Container/
│   │   └── {Feature}Container.swift        # Internal container (lazy repository)
│   ├── Domain/
│   ├── Data/
│   └── Presentation/
│       ├── {Name}List/                     # Group by screen
│       │   ├── Views/
│       │   │   └── {Name}ListView.swift
│       │   └── ViewModels/
│       │       ├── {Name}ListViewModel.swift
│       │       └── {Name}ListViewState.swift
│       └── {Name}Detail/                   # Group by screen
│           ├── Views/
│           │   └── {Name}DetailView.swift
│           └── ViewModels/
│               ├── {Name}DetailViewModel.swift
│               └── {Name}DetailViewState.swift
```

**Notes:**
- Container is at the root of Sources/, NOT inside Presentation/
- Container is accessed via static property in `{Feature}Feature` enum
- Views receive **only ViewModel** via init
- Navigation is handled by App using `NavigationPath`

---

## Navigation Destinations

Each feature defines its navigation destinations conforming to `Navigation` protocol from Core:

```swift
// Sources/{Feature}Navigation.swift
import ChallengeCore

public enum {Feature}Navigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

**Rules:**
- Conform to `Navigation` protocol (from Core module)
- Use primitive types for parameters (Int, String, Bool, UUID)
- Never pass domain objects - only identifiers

---

## Public Entry Point

Each feature exposes a **public entry point** with a static container and view builder:

```swift
// Sources/{Feature}Feature.swift
import ChallengeCore
import SwiftUI

public enum {Feature}Feature {
    private static let container = {Feature}Container()

    @ViewBuilder
    public static func view(for navigation: {Feature}Navigation, router: RouterContract) -> some View {
        switch navigation {
        case .list:
            {Name}ListView(viewModel: container.makeListViewModel(router: routerMock))
        case .detail(let identifier):
            {Name}DetailView(viewModel: container.makeDetailViewModel(identifier: identifier, router: routerMock))
        }
    }
}
```

**Rules:**
- **public enum** - Prevents instantiation, only static access
- **private static let container** - Shared container (lazy repository is source of truth)
- **view(for:router:)** - Builds view for each navigation destination, receives router from App
- **router parameter** - Passed to Container factories for ViewModel injection
- All dependency wiring happens internally

**Usage from App:**

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
            HomeFeature.makeHomeView(router: routerMock)
                .navigationDestination(for: CharacterNavigation.self) { navigation in
                    CharacterFeature.view(for: navigation, router: routerMock)
                }
        }
    }
}
```

**Notes:**
- Router is `@Observable` and owns the `NavigationPath` internally
- App creates a single Router instance per NavigationStack
- Router is passed to Features, which pass it to ViewModels
- For multiple NavigationStacks (tabs, modals), create separate Router instances

---

## Internal Container

The Container is **internal** and manages all dependencies with lazy repository:

```swift
// Sources/Container/{Feature}Container.swift
import ChallengeNetworking
import Foundation

final class {Feature}Container {
    // MARK: - Infrastructure

    private let httpClient: any HTTPClientContract

    init(httpClient: (any HTTPClientContract)? = nil) {
        guard let url = URL(string: "https://api.example.com") else {
            fatalError("Invalid API base URL")
        }
        self.httpClient = httpClient ?? HTTPClient(baseURL: url)
    }

    // MARK: - Shared (lazy) - Source of Truth

    private let memoryDataSource = {Name}MemoryDataSource()

    private lazy var repository: any {Name}RepositoryContract = {Name}Repository(
        remoteDataSource: {Name}RemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    // MARK: - Factories

    func makeListViewModel(router: RouterContract) -> {Name}ListViewModel {
        {Name}ListViewModel(
            get{Name}sUseCase: makeGet{Name}sUseCase(),
            router: router
        )
    }

    func makeDetailViewModel(identifier: Int, router: RouterContract) -> {Name}DetailViewModel {
        {Name}DetailViewModel(
            identifier: identifier,
            get{Name}UseCase: makeGet{Name}UseCase(),
            router: router
        )
    }

    private func makeGet{Name}sUseCase() -> some Get{Name}sUseCaseContract {
        Get{Name}sUseCase(repository: repository)
    }

    private func makeGet{Name}UseCase() -> some Get{Name}UseCaseContract {
        Get{Name}UseCase(repository: repository)
    }
}
```

**Rules:**
- **final class** - Allows instance properties and lazy initialization
- **httpClient via init** - Optional injection for testability, default creates HTTPClient
- **lazy var repository** - Source of truth, initialized on first access
- **Private UseCase factories** - Only ViewModels are created externally
- **Internal visibility** - Container is not public

---

## Lazy vs Factory

| Type | Pattern | Reason |
|------|---------|--------|
| HTTPClient | Optional init parameter | Injectable for tests, default creates instance |
| MemoryDataSource | Instance property | Maintains cache state |
| Repository | `lazy var` | Source of truth, initialized on first access |
| ViewModel | Factory method | New instance per navigation |
| UseCase | Factory method | Stateless, can be new |

```swift
// INIT - Optional injection with default HTTPClient
init(httpClient: (any HTTPClientContract)? = nil) {
    self.httpClient = httpClient ?? HTTPClient(baseURL: APIConfiguration.baseURL)
}

// LAZY - Source of truth, initialized on first access
private lazy var repository: any CharacterRepositoryContract = CharacterRepository(...)

// FACTORY - New instance per navigation (receives router)
func makeListViewModel(router: RouterContract) -> CharacterListViewModel {
    CharacterListViewModel(getCharactersUseCase: makeGetCharactersUseCase(), router: routerMock)
}
```

---

## Visibility Rules

| Component | Visibility | Reason |
|-----------|------------|--------|
| Contract (Protocol) | `public` | API for consumers, enables DI |
| Implementation (Class) | `public` / `open` | Direct instantiation allowed |

```swift
// ChallengeNetworking module

// PUBLIC - Contract for dependency injection
public protocol HTTPClientContract: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
}

// PUBLIC OPEN - Implementation can be used directly or subclassed
open class HTTPClient: HTTPClientContract {
    public init(baseURL: URL, session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder())
    // ...
}
```

**Why contracts matter:**
- Consumers can depend on abstractions for testability
- Mocks can be injected via contract type
- Direct instantiation is also allowed when convenient

---

## Example: CharacterFeature

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
            CharacterListView(viewModel: container.makeListViewModel(router: routerMock))
        case .detail(let identifier):
            CharacterDetailView(viewModel: container.makeDetailViewModel(identifier: identifier, router: routerMock))
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
            HomeFeature.makeHomeView(router: routerMock)
                .navigationDestination(for: CharacterNavigation.self) { navigation in
                    CharacterFeature.view(for: navigation, router: routerMock)
                }
        }
    }
}
```

---

## Visibility Summary

| Component | Visibility | Reason |
|-----------|------------|--------|
| Contract (Protocol) | **public** | API for consumers, enables DI |
| Implementation (Class) | **public** / **open** | Direct instantiation allowed |
| {Feature}Navigation | **public** | Navigation destinations |
| {Feature}Feature | **public** | Entry point with `view(for:)` |
| {Feature}Container | internal | Internal wiring |
| Views | internal | Internal UI |

---

## Testing Containers

Containers must be tested to verify correct dependency wiring. Tests should verify that factory methods return properly configured instances.

### File Structure

```
Libraries/Features/{FeatureName}/
└── Tests/
    └── Container/
        └── {Feature}ContainerTests.swift
```

### Container Tests Pattern

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
        let httpClientMock = HTTPClientMock(result: .success(CharacterDTO.stubJSONData()))
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

### Example: CharacterContainerTests

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

### Example: HomeContainerTests (Simple Container)

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

## Checklist

- [ ] Create `{Feature}Navigation.swift` conforming to `Navigation` protocol
- [ ] Create `{Feature}Feature.swift` with static container and `view(for:)` method
- [ ] Create internal Container as `final class` with optional `httpClient` in init
- [ ] Use `lazy var` for repository (source of truth)
- [ ] Views only receive ViewModel
- [ ] Use factory methods for ViewModels
- [ ] App registers `.navigationDestination(for: {Feature}Navigation.self)`
- [ ] **Create container tests verifying factory methods and shared repository**
