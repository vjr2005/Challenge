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
// Protocol definition (Domain layer)
protocol CharacterRepositoryContract: Sendable {
    func getCharacters(page: Int) async throws -> CharacterPage
    func getCharacter(id: Int) async throws -> Character
}

// Concrete implementation (Data layer)
final class CharacterRepository: CharacterRepositoryContract {
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
| **Presentation** | `CharacterListViewModelContract`, `NavigatorContract` | ViewModel abstractions for Views |
| **Domain** | `GetCharactersUseCaseContract`, `CharacterRepositoryContract` | Business logic contracts |
| **Data** | `CharacterRemoteDataSourceContract`, `HTTPClientContract` | Data access abstractions |

## Container Structure

### AppContainer

The root container that creates shared dependencies and feature containers:

```swift
public struct AppContainer: Sendable {
    // Shared dependencies
    public let httpClient: any HTTPClientContract

    // Feature containers
    private let homeFeature: HomeFeature
    private let characterFeature: CharacterFeature
    private let systemFeature: SystemFeature

    public init(httpClient: (any HTTPClientContract)? = nil) {
        // Default implementation if not provided (for production)
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: AppEnvironment.current.rickAndMorty.baseURL
        )

        // Wire features with shared dependencies
        homeFeature = HomeFeature()
        characterFeature = CharacterFeature(httpClient: self.httpClient)
        systemFeature = SystemFeature()
    }
}
```

### Feature Container

Each feature has its own container that manages its internal dependencies:

```swift
public final class CharacterContainer: Sendable {
    private let httpClient: any HTTPClientContract
    private let memoryDataSource = CharacterMemoryDataSource()

    public init(httpClient: any HTTPClientContract) {
        self.httpClient = httpClient
    }

    // Repository (created on demand)
    private var repository: any CharacterRepositoryContract {
        CharacterRepository(
            remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
            memoryDataSource: memoryDataSource
        )
    }

    // Factory methods for ViewModels
    func makeCharacterListViewModel(navigator: any NavigatorContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: repository),
            searchCharactersUseCase: SearchCharactersUseCase(repository: repository),
            navigator: CharacterListNavigator(navigator: navigator)
        )
    }
}
```

## Dependency Flow

```
AppContainer
    │
    ├── HTTPClient (shared)
    │
    └── CharacterFeature
            │
            └── CharacterContainer
                    │
                    ├── CharacterRemoteDataSource ← HTTPClient
                    ├── CharacterMemoryDataSource
                    │
                    └── CharacterRepository ← DataSources
                            │
                            ├── GetCharactersUseCase ← Repository
                            │
                            └── CharacterListViewModel ← UseCases, Navigator
```

## Testing

The protocol-based approach enables easy testing by injecting mocks:

```swift
@Test("Fetches characters from repository")
func fetchesCharacters() async throws {
    // Given - Inject mock instead of real implementation
    let repositoryMock = CharacterRepositoryMock()
    repositoryMock.getCharactersResult = .success(.stub())

    let sut = GetCharactersUseCase(repository: repositoryMock)

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
```

## Rules

1. **Constructor injection only**: All dependencies through initializers
2. **Protocol types**: Depend on `any ProtocolContract`, not concrete types
3. **No singletons**: Avoid global state, pass dependencies explicitly
4. **Container per feature**: Each feature manages its own internal wiring
5. **Shared dependencies**: Cross-feature dependencies live in `AppContainer`
