---
name: dependency-injection
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
│       ├── Views/
│       │   ├── {Name}ListView.swift        # List view (receives ViewModel only)
│       │   └── {Name}DetailView.swift      # Detail view (receives ViewModel only)
│       └── ViewModels/
│           ├── {Name}ListViewModel.swift
│           └── {Name}DetailViewModel.swift
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

    @MainActor @ViewBuilder
    public static func view(for navigation: {Feature}Navigation) -> some View {
        switch navigation {
        case .list:
            {Name}ListView(viewModel: container.makeListViewModel())
        case .detail(let identifier):
            {Name}DetailView(viewModel: container.makeDetailViewModel(identifier: identifier))
        }
    }
}
```

**Rules:**
- **public enum** - Prevents instantiation, only static access
- **private static let container** - Shared container (lazy repository is source of truth)
- **view(for:)** - Builds view for each navigation destination
- All dependency wiring happens internally

**Usage from App:**

```swift
// In App module
import ChallengeCharacter
import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: CharacterNavigation.self) { navigation in
                    CharacterFeature.view(for: navigation)
                }
        }
    }
}

// Navigate from anywhere with access to path
path.append(CharacterNavigation.detail(identifier: 42))
```

---

## Internal Container

The Container is **internal** and manages all dependencies with lazy repository:

```swift
// Sources/Container/{Feature}Container.swift
import ChallengeNetworking
import Foundation

final class {Feature}Container {
    // MARK: - Infrastructure

    private static let defaultHTTPClient: any HTTPClientContract = {
        guard let url = URL(string: "https://api.example.com") else {
            fatalError("Invalid API base URL")
        }
        return Networking.makeHTTPClient(baseURL: url)
    }()

    private let httpClient: any HTTPClientContract

    init(httpClient: any HTTPClientContract = Self.defaultHTTPClient) {
        self.httpClient = httpClient
    }

    // MARK: - Shared (lazy) - Source of Truth

    private let memoryDataSource = {Name}MemoryDataSource()

    private lazy var repository: any {Name}RepositoryContract = {Name}Repository(
        remoteDataSource: {Name}RemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    // MARK: - Factories

    func makeListViewModel() -> {Name}ListViewModel {
        {Name}ListViewModel(
            get{Name}sUseCase: makeGet{Name}sUseCase()
        )
    }

    func makeDetailViewModel(identifier: Int) -> {Name}DetailViewModel {
        {Name}DetailViewModel(
            identifier: identifier,
            get{Name}UseCase: makeGet{Name}UseCase()
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
- **httpClient via init** - Injected with default value for testability
- **lazy var repository** - Source of truth, initialized on first access
- **Private UseCase factories** - Only ViewModels are created externally
- **Internal visibility** - Container is not public

---

## Lazy vs Factory

| Type | Pattern | Reason |
|------|---------|--------|
| HTTPClient | Static + Init parameter | Shared default, injectable for tests |
| MemoryDataSource | Instance property | Maintains cache state |
| Repository | `lazy var` | Source of truth, initialized on first access |
| ViewModel | Factory method | New instance per navigation |
| UseCase | Factory method | Stateless, can be new |

```swift
// STATIC DEFAULT - Shared instance for production
private static let defaultHTTPClient: any HTTPClientContract = {
    guard let url = URL(string: "https://api.example.com") else {
        fatalError("Invalid API base URL")
    }
    return Networking.makeHTTPClient(baseURL: url)
}()

// INIT - Injected dependency with default
init(httpClient: any HTTPClientContract = Self.defaultHTTPClient) {
    self.httpClient = httpClient
}

// LAZY - Source of truth, initialized on first access
private lazy var repository: any CharacterRepositoryContract = CharacterRepository(...)

// FACTORY - New instance per navigation
func makeListViewModel() -> CharacterListViewModel {
    CharacterListViewModel(getCharactersUseCase: makeGetCharactersUseCase())
}
```

---

## Visibility Rules

**Never expose implementations, only contracts:**

| Component | Visibility | Reason |
|-----------|------------|--------|
| Contract (Protocol) | `public` | API for consumers |
| Implementation (Class) | `internal` | Hidden from consumers |
| Module enum | `public` | Entry point with factory methods |

```swift
// ChallengeNetworking module

// PUBLIC - Contract exposed to consumers
public protocol HTTPClientContract: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
}

// INTERNAL - Implementation hidden from consumers
final class HTTPClient: HTTPClientContract {
    // ...
}

// PUBLIC - Module entry point with factory methods
public enum Networking {
    public static func makeHTTPClient(baseURL: URL) -> any HTTPClientContract {
        HTTPClient(baseURL: baseURL)
    }
}
```

**Why this matters:**
- Consumers depend on abstractions (contracts), not implementations
- Implementations can change without breaking consumers
- Testing is easier with contract-based injection

---

## Shared Dependencies

Infrastructure dependencies are created via **module entry points** that expose factory methods:

```swift
// In feature Container - uses module entry point
private static let defaultHTTPClient: any HTTPClientContract = {
    guard let url = URL(string: "https://api.example.com") else {
        fatalError("Invalid API base URL")
    }
    return Networking.makeHTTPClient(baseURL: url)
}()

init(httpClient: any HTTPClientContract = Self.defaultHTTPClient) {
    self.httpClient = httpClient
}
```

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

    @MainActor @ViewBuilder
    public static func view(for navigation: CharacterNavigation) -> some View {
        switch navigation {
        case .list:
            CharacterListView(viewModel: container.makeListViewModel())
        case .detail(let identifier):
            CharacterDetailView(viewModel: container.makeDetailViewModel(identifier: identifier))
        }
    }
}
```

### Internal Container

```swift
// Sources/Container/CharacterContainer.swift
import ChallengeNetworking
import Foundation

final class CharacterContainer {
    // MARK: - Infrastructure

    private static let defaultHTTPClient: any HTTPClientContract = {
        guard let url = URL(string: "https://rickandmortyapi.com/api") else {
            fatalError("Invalid API base URL")
        }
        return Networking.makeHTTPClient(baseURL: url)
    }()

    private let httpClient: any HTTPClientContract

    init(httpClient: any HTTPClientContract = Self.defaultHTTPClient) {
        self.httpClient = httpClient
    }

    // MARK: - Shared (lazy) - Source of Truth

    private let memoryDataSource = CharacterMemoryDataSource()

    private lazy var repository: any CharacterRepositoryContract = CharacterRepository(
        remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    // MARK: - Factories

    func makeListViewModel() -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: makeGetCharactersUseCase()
        )
    }

    func makeDetailViewModel(identifier: Int) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: makeGetCharacterUseCase()
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
import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: CharacterNavigation.self) { navigation in
                    CharacterFeature.view(for: navigation)
                }
        }
    }
}

// Navigate from anywhere
path.append(CharacterNavigation.list)
path.append(CharacterNavigation.detail(identifier: 42))
```

---

## Visibility Summary

| Component | Visibility | Reason |
|-----------|------------|--------|
| Contract (Protocol) | **public** | API for consumers |
| Implementation (Class) | internal | Hidden from consumers |
| Module entry point enum | **public** | Factory methods for infrastructure modules |
| {Feature}Navigation | **public** | Navigation destinations |
| {Feature}Feature | **public** | Entry point with `view(for:)` |
| {Feature}Container | internal | Internal wiring |
| Views | internal | Internal UI |

---

## Checklist

- [ ] **Contracts are public, implementations are internal**
- [ ] Infrastructure modules use entry point enum (e.g., `Networking.makeHTTPClient()`)
- [ ] Create `{Feature}Navigation.swift` conforming to `Navigation` protocol
- [ ] Create `{Feature}Feature.swift` with static container and `view(for:)` method
- [ ] Create internal Container as `final class` with `httpClient` in init
- [ ] Use `lazy var` for repository (source of truth)
- [ ] Views only receive ViewModel
- [ ] Use factory methods for ViewModels
- [ ] App registers `.navigationDestination(for: {Feature}Navigation.self)`
