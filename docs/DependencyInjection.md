# Dependency Injection

The project uses **manual dependency injection** with the **Composition Root** pattern. All dependencies are created at the app's entry point and propagated through initializers.

## Composition Root Pattern

The Composition Root is the **single location** where the entire object graph is composed. In this project, `AppContainer` serves as the Composition Root.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AppContainer (Composition Root)                     │
│                                                                             │
│   Creates shared dependencies and feature containers                        │
│                                                                             │
│   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│   │ CharacterFeature│  │   HomeFeature   │  │  SystemFeature  │             │
│   │    Container    │  │    Container    │  │    Container    │             │
│   └────────┬────────┘  └────────┬────────┘  └────────┬────────┘             │
│            │                    │                    │                      │
│            ▼                    ▼                    ▼                      │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │                    Factory Methods                              │       │
│   │         Creates ViewModels with all dependencies wired          │       │
│   └─────────────────────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Benefits

- **Single source of truth**: All dependencies are created in one place
- **Easy to test**: Replace the entire container or individual dependencies
- **No service locator**: Dependencies are explicit, not resolved at runtime
- **Compile-time safety**: Missing dependencies cause build errors, not runtime crashes

## Protocol-Based Abstractions

All dependencies are defined as **protocols** (named with `Contract` suffix). Concrete implementations are only known at the Composition Root.

```swift
// Protocol definitions (Domain layer)
protocol CharacterRepositoryContract: Sendable {
    func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
}

protocol CharactersPageRepositoryContract: Sendable {
    func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage
    func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage
}

// Concrete implementations (Data layer)
struct CharacterRepository: CharacterRepositoryContract {
    private let remoteDataSource: any CharacterRemoteDataSourceContract
    private let memoryDataSource: any CharacterMemoryDataSourceContract

    // Dependencies injected through initializer
    init(
        remoteDataSource: any CharacterRemoteDataSourceContract,
        memoryDataSource: any CharacterMemoryDataSourceContract
    ) {
        self.remoteDataSource = remoteDataSource
        self.memoryDataSource = memoryDataSource
    }
}
```

### Protocol Layers

| Layer | Protocol Examples | Purpose |
|-------|-------------------|---------|
| **Presentation** | `CharacterListViewModelContract`, `NavigatorContract`, `TrackerContract` | ViewModel abstractions for Views |
| **Domain** | `GetCharactersPageUseCaseContract`, `CharacterRepositoryContract`, `CharactersPageRepositoryContract` | Business logic contracts |
| **Data** | `CharacterRemoteDataSourceContract`, `HTTPClientContract` | Data access abstractions |

## Container Structure

### AppContainer

The root container that creates shared dependencies and feature containers:

```swift
public struct AppContainer {
    // Shared dependencies
    public let httpClient: any HTTPClientContract
    public let tracker: any TrackerContract
    public let imageLoader: any ImageLoaderContract

    // Feature containers
    private let homeFeature: HomeFeature
    private let characterFeature: CharacterFeature
    private let systemFeature: SystemFeature

    public init(
        httpClient: (any HTTPClientContract)? = nil,
        tracker: (any TrackerContract)? = nil,
        imageLoader: (any ImageLoaderContract)? = nil
    ) {
        self.imageLoader = imageLoader ?? CachedImageLoader()
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: AppEnvironment.current.rickAndMorty.baseURL
        )
        let providers = Self.makeTrackingProviders()
        providers.forEach { $0.configure() }
        self.tracker = tracker ?? Tracker(providers: providers)

        // Wire features with shared dependencies
        homeFeature = HomeFeature(tracker: self.tracker)
        characterFeature = CharacterFeature(httpClient: self.httpClient, tracker: self.tracker)
        systemFeature = SystemFeature(tracker: self.tracker)
    }

    private static func makeTrackingProviders() -> [any TrackingProviderContract] {
        [ConsoleTrackingProvider()]
    }
}
```

### Feature Container

Each feature has its own container that manages its internal dependencies:

```swift
public final class CharacterContainer {
    private let tracker: any TrackerContract

    private let characterRepository: any CharacterRepositoryContract
    private let recentSearchesRepository: any RecentSearchesRepositoryContract
    private let charactersPageRepository: any CharactersPageRepositoryContract

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

    // Factory methods for ViewModels
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

## Dependency Flow

```
AppContainer
    │
    ├── HTTPClient (shared)
    ├── Tracker (shared) ← [Providers]
    ├── ImageLoader (shared) → injected via SwiftUI Environment
    │
    └── CharacterFeature
            │
            └── CharacterContainer
                    │
                    ├── CharacterRemoteDataSource ← HTTPClient
                    ├── CharacterMemoryDataSource
                    ├── RecentSearchesLocalDataSource
                    │
                    ├── CharacterRepository ← Remote + Memory DataSources
                    ├── CharactersPageRepository ← Remote + Memory DataSources
                    └── RecentSearchesRepository ← Local DataSource
                            │
                            ├── GetCharactersPageUseCase ← Repository
                            ├── GetRecentSearchesUseCase ← Repository
                            │
                            ├── CharacterListViewModel ← UseCases, Navigator, Tracker
                            │       (conforms to CharacterFilterDelegate)
                            │
                            └── AdvancedSearchViewModel ← Delegate, Navigator, Tracker
```

## Testing

The protocol-based approach enables easy testing by injecting mocks:

```swift
@Test("Fetches characters from repository")
func fetchesCharacters() async throws {
    // Given - Inject mock instead of real implementation
    let repositoryMock = CharactersPageRepositoryMock()
    repositoryMock.charactersResult = .success(.stub())

    let sut = GetCharactersPageUseCase(repository: repositoryMock)

    // When
    let result = try await sut.execute(page: 1)

    // Then
    #expect(result.characters.count == 2)
}
```

### Testing AppContainer

```swift
@Test("AppContainer uses injected HTTP client")
func usesInjectedClient() {
    // Given - Inject mock HTTP client
    let httpClientMock = HTTPClientMock()

    // When
    let container = AppContainer(httpClient: httpClientMock)

    // Then
    #expect(container.httpClient === httpClientMock)
}

@Test("AppContainer uses injected tracker")
func usesInjectedTracker() {
    // Given - Inject mock tracker
    let trackerMock = TrackerMock()

    // When
    let container = AppContainer(tracker: trackerMock)

    // Then
    #expect(container.tracker === trackerMock)
}
```

## Rules

1. **Constructor injection only**: All dependencies through initializers
2. **Protocol types**: Depend on `any ProtocolContract`, not concrete types
3. **No singletons**: Avoid global state, pass dependencies explicitly
4. **Container per feature**: Each feature manages its own internal wiring
5. **Shared dependencies**: Cross-feature dependencies live in `AppContainer`
