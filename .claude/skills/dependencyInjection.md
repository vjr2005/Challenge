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
│   ├── {Feature}Feature.swift              # Public entry point
│   ├── Container/
│   │   └── {Feature}Container.swift        # Internal container
│   ├── Domain/
│   ├── Data/
│   └── Presentation/
│       ├── Views/
│       │   ├── {Feature}RootView.swift     # Root view (owns Router, uses Container)
│       │   ├── {Name}ListView.swift        # List view (receives ViewModel only)
│       │   └── {Name}DetailView.swift      # Detail view (receives ViewModel only)
│       ├── ViewModels/
│       │   ├── {Name}ListViewModel.swift   # Has Router for navigation
│       │   └── {Name}DetailViewModel.swift # No Router (leaf view)
│       └── Router/
```

**Notes:**
- Container is at the root of Sources/, NOT inside Presentation/. It's a cross-cutting concern that wires all layers.
- Only RootView accesses Container directly. Other Views receive **only ViewModel** via init.
- Router is injected into ViewModel, **not into View**.

---

## Public Entry Point

Each feature exposes a **public entry point** that the App uses to navigate:

```swift
// Sources/{Feature}Feature.swift
import SwiftUI

public enum {Feature}Feature {
    public static func makeRootView() -> some View {
        {Feature}View()
    }
}
```

**Rules:**
- **public enum** - Prevents instantiation, only static access
- **makeRootView()** - Returns the root View of the feature
- **Opaque return type** - Use `some View` to hide internal types
- App only knows about this public interface

**Usage from App:**

```swift
// In App module
import Challenge{Feature}

NavigationLink("Go to Feature") {
    {Feature}Feature.makeRootView()
}
```

---

## Internal Container

The Container is **internal** and manages all dependencies:

```swift
// Sources/Container/{Feature}Container.swift
import ChallengeNetworking
import Foundation

final class {Feature}Container {
    // MARK: - Infrastructure

    private let httpClient: any HTTPClientContract

    init(httpClient: any HTTPClientContract = ChallengeNetworking.sharedHTTPClient) {
        self.httpClient = httpClient
    }

    // MARK: - Shared (lazy)

    private let memoryDataSource = {Name}MemoryDataSource()

    private lazy var repository: any {Name}RepositoryContract = {Name}Repository(
        remoteDataSource: {Name}RemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    // MARK: - Factories

    func makeRouter() -> {Feature}Router {
        {Feature}Router()
    }

    func makeListViewModel(router: {Feature}Router) -> {Name}ListViewModel {
        {Name}ListViewModel(
            get{Name}sUseCase: makeGet{Name}sUseCase(),
            router: router
        )
    }

    func makeDetailViewModel(itemId: Int) -> {Name}DetailViewModel {
        {Name}DetailViewModel(
            itemId: itemId,
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
- **lazy var repository** - Initialized on first access
- **Private UseCase factories** - Only ViewModels are created externally
- **Internal visibility** - Container is not public

---

## Lazy vs Factory

| Type | Pattern | Reason |
|------|---------|--------|
| HTTPClient | Init parameter | Injected for testability |
| MemoryDataSource | Instance property | Maintains cache state |
| Repository | `lazy var` | Initialized on first access |
| ViewModel | Factory method | New instance per View |
| UseCase | Factory method | Stateless, can be new |
| Router | Factory method | New instance per navigation stack |

```swift
// INIT - Injected dependency
init(httpClient: any HTTPClientContract = ChallengeNetworking.sharedHTTPClient) {
    self.httpClient = httpClient
}

// LAZY - Initialized on first access
private lazy var repository: any CharacterRepositoryContract = CharacterRepository(...)

// FACTORY - New instance
func makeListViewModel(router: CharacterRouter) -> CharacterListViewModel {
    CharacterListViewModel(getCharactersUseCase: makeGetCharactersUseCase(), router: router)
}
```

---

## Shared Dependencies

Infrastructure dependencies (HTTPClient) are exposed by their modules:

```swift
// In ChallengeNetworking module
public let sharedHTTPClient: any HTTPClientContract = {
    guard let url = URL(string: "https://api.example.com") else {
        fatalError("Invalid API base URL")
    }
    return HTTPClient(baseURL: url)
}()

// In feature Container
static var httpClient: any HTTPClientContract { ChallengeNetworking.sharedHTTPClient }
```

---

## Root View Pattern

The root View of a feature creates Container and Router:

```swift
// Sources/Presentation/Views/{Feature}RootView.swift
import SwiftUI

struct {Feature}RootView: View {
    private let container = {Feature}Container()
    @State private var router: {Feature}Router

    init() {
        let container = {Feature}Container()
        self.container = container
        _router = State(initialValue: container.makeRouter())
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            {Name}ListView(
                viewModel: container.makeListViewModel(router: router)
            )
            .navigationDestination(for: {Feature}Router.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: {Feature}Router.Destination) -> some View {
        switch destination {
        case .detail(let item):
            {Name}DetailView(
                viewModel: container.makeDetailViewModel(itemId: item.id)
            )
        }
    }
}
```

**Rules:**
- **RootView owns Container** as instance (not static)
- **RootView owns Router** via `@State`
- **Router injected to ViewModel** via Container factory method
- **Views only receive ViewModel** - no Router in Views (see `/view` skill)
- Container is only accessed from RootView, not child Views

---

## Example: CharacterFeature

### Public Entry Point

```swift
// Sources/CharacterFeature.swift
import SwiftUI

public enum CharacterFeature {
    public static func makeRootView() -> some View {
        CharacterRootView()
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

    private let httpClient: any HTTPClientContract

    init(httpClient: any HTTPClientContract = ChallengeNetworking.sharedHTTPClient) {
        self.httpClient = httpClient
    }

    // MARK: - Shared (lazy)

    private let memoryDataSource = CharacterMemoryDataSource()

    private lazy var repository: any CharacterRepositoryContract = CharacterRepository(
        remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    // MARK: - Factories

    func makeRouter() -> CharacterRouter {
        CharacterRouter()
    }

    func makeListViewModel(router: CharacterRouter) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: makeGetCharactersUseCase(),
            router: router
        )
    }

    func makeDetailViewModel(characterId: Int) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            characterId: characterId,
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

### Root View

```swift
// Sources/Presentation/Views/CharacterRootView.swift
import SwiftUI

struct CharacterRootView: View {
    private let container: CharacterContainer
    @State private var router: CharacterRouter

    init() {
        let container = CharacterContainer()
        self.container = container
        _router = State(initialValue: container.makeRouter())
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            CharacterListView(
                viewModel: container.makeListViewModel(router: router)
            )
            .navigationDestination(for: CharacterRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: CharacterRouter.Destination) -> some View {
        switch destination {
        case .detail(let character):
            CharacterDetailView(
                viewModel: container.makeDetailViewModel(characterId: character.id)
            )
        }
    }
}
```

### Usage from App

```swift
// In App/Sources/ContentView.swift
import ChallengeCharacter
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Characters") {
                    CharacterFeature.makeRootView()
                }
            }
        }
    }
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| {Feature}Feature | **public** | `Sources/{Feature}Feature.swift` |
| {Feature}Container | internal | `Sources/Container/` |
| {Feature}RootView | internal | `Sources/Presentation/Views/` |

---

## Checklist

- [ ] Create public entry point `{Feature}Feature.swift` with `makeRootView()`
- [ ] Create internal Container as `final class` with `httpClient` in init
- [ ] Use `lazy var` for repository
- [ ] Create root view `{Feature}RootView.swift` that owns Container and Router
- [ ] Container's `makeListViewModel(router:)` receives Router parameter
- [ ] Views only receive ViewModel (no Router)
- [ ] Use factory methods for ViewModels
- [ ] Verify App can navigate using only the public entry point
