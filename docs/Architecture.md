# Architecture

The project follows **MVVM + Clean Architecture** with feature-based modularization.

## Overview

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                    Presentation Layer                       │
                    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
                    │  │    View     │  │  ViewModel  │──│     Navigator       │  │
                    │  │  (SwiftUI)  │◄─┤ @Observable │  │ (NavigatorContract) │  │
                    │  └─────────────┘  │             │  └─────────────────────┘  │
                    │                   │             │  ┌─────────────────────┐  │
                    │                   │             │──│      Tracker        │  │
                    │                   └─────────────┘  │ (TrackerContract)   │  │
                    │                                    └─────────────────────┘  │
                    └─────────────────────────────────────────────────────────────┘
                                                │
                                                ▼
                    ┌─────────────────────────────────────────────────────────────┐
                    │                      Domain Layer                           │
                    │  ┌─────────────────────┐  ┌─────────────────────────────┐   │
                    │  │      Use Case       │  │         Models              │   │
                    │  │  (Business Logic)   │  │    (Domain Models)          │   │
                    │  └─────────────────────┘  └─────────────────────────────┘   │
                    └─────────────────────────────────────────────────────────────┘
                                                │
                                                ▼
                    ┌─────────────────────────────────────────────────────────────┐
                    │                       Data Layer                            │
                    │  ┌─────────────────────┐  ┌─────────────────────────────┐   │
                    │  │     Repository      │  │       Data Source           │   │
                    │  │  (Implementation)   │  │  (REST/GraphQL/SwiftData)   │   │
                    │  └─────────────────────┘  └─────────────────────────────┘   │
                    └─────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| **Presentation** | UI components, ViewModels with state management, navigation, tracking |
| **Domain** | Business logic (UseCases), domain models, repository contracts |
| **Data** | Repository implementations, data sources (REST, GraphQL, SwiftData, UserDefaults), DTOs, SwiftData entities |

## SOLID Principles

The codebase adheres to SOLID principles to ensure maintainable, extensible, and testable code:

| Principle | Description | Example in Codebase |
|-----------|-------------|---------------------|
| **S**ingle Responsibility | Each class/struct has only one reason to change | `GetCharactersPageUseCase` only handles fetching characters page; `CharacterViewModel` only manages character list state |
| **O**pen/Closed | Open for extension, closed for modification | Protocols like `CharacterRepositoryContract` allow new implementations without modifying existing code |
| **L**iskov Substitution | Subtypes must be substitutable for their base types | `CharacterRepositoryMock` substitutes `CharacterRepository` via `CharacterRepositoryContract` in tests |
| **I**nterface Segregation | Prefer small, specific protocols over large ones | Separate contracts for `CharacterRepositoryContract`, `CharactersPageRepositoryContract` instead of one large protocol |
| **D**ependency Inversion | Depend on abstractions, not concrete implementations | ViewModels depend on UseCase protocols; Repositories depend on DataSource protocols |

### Practical Application

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Dependency Inversion                               │
│                                                                             │
│   ViewModel ──► UseCaseContract ◄── UseCase ──► RepositoryContract ◄── Repo │
│                   (Protocol)                      (Protocol)                │
│                                                                             │
│   High-level modules depend on abstractions, not concrete implementations   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Benefits

- **Testability**: Mock any layer by implementing its protocol
- **Flexibility**: Swap implementations (e.g., remote vs. memory data source) without changing dependent code
- **Maintainability**: Changes in one layer don't ripple through the entire codebase

## Repository Pattern

The Repository pattern acts as a **boundary between Domain and Data layers**, providing a clean API for data access while hiding implementation details like caching, networking, and data mapping.

### Separation of Responsibilities

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DOMAIN LAYER                                   │
│                                                                             │
│   UseCase ──► CharacterRepositoryContract (detail)                          │
│              CharactersPageRepositoryContract (list/search)                 │
│                        │                                                    │
│                        │  • Works with Domain Models (Character)            │
│                        │  • Doesn't know about DTOs, HTTP, or caching       │
│                        │  • Throws domain-specific typed errors              │
└────────────────────────┼────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                               DATA LAYER                                    │
│                                                                             │
│   CharacterRepository (Implementation)                                      │
│           │                                                                 │
│           ├── RemoteDataSource ──► REST or GraphQL API (DTOs)               │
│           ├── VolatileDataSource ──► In-memory SwiftData (Entities → DTOs)  │
│           ├── PersistenceDataSource ──► On-disk SwiftData (Entities → DTOs) │
│           ├── Mapper → DTO to Domain mapping                                │
│           └── Error Mapper → APIError to Domain error mapping               │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Contract Definition (Domain Layer)

The contract defines **what** operations are available, using only domain types:

```swift
// Domain layer - no knowledge of Data layer implementation
protocol CharacterRepositoryContract: Sendable {
    func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
}

protocol CharactersPageRepositoryContract: Sendable {
    func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage
    func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage
}
```

### Implementation (Data Layer)

Each contract has its own implementation that handles **how** data is fetched, cached, and transformed:

```swift
struct CharacterRepository: CharacterRepositoryContract {
    private let remoteDataSource: CharacterRemoteDataSourceContract
    private let volatileDataSource: CharacterLocalDataSourceContract
    private let persistenceDataSource: CharacterLocalDataSourceContract
    private let cacheExecutor = CachePolicyExecutor()

    func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
        try await cacheExecutor.execute(
            policy: cachePolicy,
            fetchFromRemote: { try await remoteDataSource.fetchCharacter(identifier: identifier) },
            getFromVolatile: { await volatileDataSource.getCharacter(identifier: identifier) },
            getFromPersistence: { await persistenceDataSource.getCharacter(identifier: identifier) },
            saveToVolatile: { await volatileDataSource.saveCharacter($0) },
            saveToPersistence: { await persistenceDataSource.saveCharacter($0) },
            mapper: { mapper.map($0) },
            errorMapper: { errorMapper.map(CharacterErrorMapperInput(error: $0, identifier: identifier)) }
        )
    }
}
```

The `CachePolicyExecutor` coordinates a two-level cache: L1 (volatile, in-memory SwiftData) and L2 (persistence, on-disk SwiftData). Both data sources implement the same `CharacterLocalDataSourceContract` — the difference is the backing `ModelContainer` (in-memory vs disk).

### Caching Strategies

The repository supports multiple caching policies through the `CachePolicy` enum (defined in `ChallengeCore`):

| Policy | Behavior | Use Case |
|--------|----------|----------|
| `.localFirst` | Cache first, remote if not found | Default, best for static data |
| `.remoteFirst` | Remote first, cache as fallback on error | Fresh data with offline support |
| `.noCache` | Always fetch from remote, no caching | Real-time data, search queries |

```swift
// Libraries/Core/Sources/Data/CachePolicy.swift
public enum CachePolicy {
    case localFirst   // Cache → Remote
    case remoteFirst  // Remote → Cache (fallback)
    case noCache      // Remote only
}
```

### DTO to Domain Mapping

The repository transforms Data Transfer Objects (DTOs) into Domain Models, keeping the Domain layer clean:

```swift
// Data layer - DTO from API
struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String  // Raw string from API
    let image: String   // URL as string
}

// Domain layer - Clean model
struct Character: Equatable {
    let id: Int
    let name: String
    let status: CharacterStatus  // Type-safe enum
    let imageURL: URL?           // Proper URL type
}

// Mapping via MapperContract (in Data/Mappers/)
struct CharacterMapper: MapperContract {
    func map(_ input: CharacterDTO) -> Character {
        Character(
            id: input.id,
            name: input.name,
            status: CharacterStatus(from: input.status),
            imageURL: URL(string: input.image)
        )
    }
}

// Usage in Repository
struct CharacterRepository: CharacterRepositoryContract {
    private let mapper = CharacterMapper()

    func getCharacter(...) async throws(CharacterError) -> Character {
        let dto = try await remoteDataSource.fetchCharacter(identifier: identifier)
        return mapper.map(dto)  // DTO → Domain via Mapper
    }
}
```

### Error Mapping

Error mapping uses dedicated **Error Mapper types** that conform to `MapperContract`, keeping repositories focused on data access orchestration:

```swift
// Sources/Data/Mappers/CharacterErrorMapper.swift
struct CharacterErrorMapperInput {
    let error: any Error
    let identifier: Int
}

struct CharacterErrorMapper: MapperContract {
    func map(_ input: CharacterErrorMapperInput) -> CharacterError {
        guard let apiError = input.error as? APIError else {
            return .loadFailed(description: String(describing: input.error))
        }
        return switch apiError {
        case .notFound:
            .notFound(identifier: input.identifier)
        case .invalidRequest, .invalidResponse, .serverError, .decodingFailed:
            .loadFailed(description: String(describing: apiError))
        }
    }
}
```

```swift
// In Repository — single catch block delegates all error mapping
private let errorMapper = CharacterErrorMapper()

func fetchFromRemote(identifier: Int) async throws(CharacterError) -> CharacterDTO {
    do {
        return try await remoteDataSource.fetchCharacter(identifier: identifier)
    } catch {
        throw errorMapper.map(CharacterErrorMapperInput(error: error, identifier: identifier))
    }
}
```

### Repository Benefits

| Benefit | Description |
|---------|-------------|
| **Separation of concerns** | Domain doesn't know about HTTP, caching, or DTOs |
| **Testability** | Mock the repository contract to test UseCases in isolation |
| **Flexibility** | Change caching strategy without affecting Domain layer |
| **Single source of truth** | All data access goes through the repository |
| **Error abstraction** | Domain works with meaningful errors, not HTTP codes |

## Feature Communication (Outgoing/Incoming Navigation)

Features must remain **independent** - they cannot import or reference each other. To enable cross-feature navigation without coupling, the project uses the **Outgoing/Incoming Navigation** pattern.

### The Problem

```
❌ Direct coupling (FORBIDDEN)

HomeFeature ──imports──► CharacterFeature
     │
     └── navigateToCharacters() {
             navigator.navigate(to: CharacterIncomingNavigation.list)  // Requires import!
         }
```

### The Solution

```
✅ Outgoing/Incoming pattern (DECOUPLED)

┌──────────────────┐                        ┌──────────────────┐
│   HomeFeature    │                        │ CharacterFeature │
│                  │                        │                  │
│ OutgoingNav:     │    AppNavigationRedirect    │ IncomingNav:     │
│  .characters ────┼────────────────────────┼──► .list         │
│                  │        (AppKit)        │                  │
└──────────────────┘                        └──────────────────┘

Home only knows "I want to go to characters" (Outgoing)
Character only knows "Someone wants to see the list" (Incoming)
AppKit connects them without either knowing about the other
```

### Implementation

**1. Outgoing Navigation (Source Feature)**

The feature declares what it wants to navigate TO, without knowing the destination:

```swift
// HomeFeature - declares outgoing intent
public enum HomeOutgoingNavigation: OutgoingNavigationContract {
    case characters  // "I want to navigate to characters"
}

// CharacterFeature - declares outgoing intent
public enum CharacterOutgoingNavigation: OutgoingNavigationContract {
    case episodes(characterIdentifier: Int)  // "I want to see episodes for this character"
}

// EpisodeFeature - declares outgoing intent
public enum EpisodeOutgoingNavigation: OutgoingNavigationContract {
    case characterDetail(identifier: Int)  // "I want to see this character's detail"
}
```

**2. Incoming Navigation (Target Feature)**

The feature declares what it can receive, without knowing who sends it:

```swift
// CharacterFeature - declares what it can handle
public enum CharacterIncomingNavigation: IncomingNavigationContract {
    case list
    case detail(identifier: Int)
}

// EpisodeFeature - declares what it can handle
public enum EpisodeIncomingNavigation: IncomingNavigationContract {
    case characterEpisodes(characterIdentifier: Int)
}
```

**3. Navigator (Source Feature)**

Uses outgoing navigation without importing the target feature:

```swift
struct HomeNavigator: HomeNavigatorContract {
    private let navigator: NavigatorContract

    func navigateToCharacters() {
        // Uses HomeOutgoingNavigation, NOT CharacterIncomingNavigation
        navigator.navigate(to: HomeOutgoingNavigation.characters)
    }
}
```

**4. Navigation Redirect (AppKit)**

The Composition Root connects outgoing to incoming:

```swift
// AppKit - the ONLY place that knows all features
public struct AppNavigationRedirect: NavigationRedirectContract {
    public func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)? {
        switch navigation {
        case let outgoing as HomeOutgoingNavigation:
            redirect(outgoing)
        case let outgoing as CharacterOutgoingNavigation:
            redirect(outgoing)
        case let outgoing as EpisodeOutgoingNavigation:
            redirect(outgoing)
        default:
            nil
        }
    }

    private func redirect(_ navigation: HomeOutgoingNavigation) -> any NavigationContract {
        switch navigation {
        case .characters:
            CharacterIncomingNavigation.list
        }
    }

    private func redirect(_ navigation: CharacterOutgoingNavigation) -> any NavigationContract {
        switch navigation {
        case let .episodes(characterIdentifier):
            EpisodeIncomingNavigation.characterEpisodes(characterIdentifier: characterIdentifier)
        }
    }

    private func redirect(_ navigation: EpisodeOutgoingNavigation) -> any NavigationContract {
        switch navigation {
        case let .characterDetail(identifier):
            CharacterIncomingNavigation.detail(identifier: identifier)
        }
    }
}
```

### Navigation Flow

```
1. User taps "Go to Characters" in HomeView
                    │
                    ▼
2. HomeNavigator.navigateToCharacters()
                    │
                    ▼
3. navigator.navigate(to: HomeOutgoingNavigation.characters)
                    │
                    ▼
4. AppNavigationRedirect.redirect() transforms:
   HomeOutgoingNavigation.characters → CharacterIncomingNavigation.list
                    │
                    ▼
5. AppContainer.resolveView(for: CharacterIncomingNavigation.list, navigator:)
                    │
                    ▼
6. CharacterFeature returns CharacterListView
```

### Benefits

| Benefit | Description |
|---------|-------------|
| **Zero coupling** | Features never import each other |
| **Testable** | Test navigation by checking outgoing events |
| **Flexible** | Change routing in one place (AppNavigationRedirect) |
| **Scalable** | Add new features without modifying existing ones |
| **Type-safe** | Compiler ensures all cases are handled |

## Modal Navigation

In addition to push navigation, the system supports **modal presentations** (sheet and fullScreenCover). Each modal gets its own `NavigationStack`, enabling push navigation within modals and recursive nesting (modals inside modals).

### Modal Presentation Styles

| Style | Description |
|-------|-------------|
| `.sheet(detents:)` | Partial or full sheet with configurable detents (default: `[.large]`) |
| `.fullScreenCover` | Full-screen cover |

### Modal Navigation Flow

```
1. User taps "Filter" in CharacterListView
                    │
                    ▼
2. CharacterListNavigator.presentFilter()
                    │
                    ▼
3. navigator.present(CharacterIncomingNavigation.filter, style: .sheet(detents: [.medium, .large]))
                    │
                    ▼
4. NavigationCoordinator.present() → sheetNavigation = ModalNavigation(...)
                    │
                    ▼
5. NavigationContainerView .sheet(item:) activates
                    │
                    ▼
6. ModalContainerView creates its own NavigationCoordinator + NavigationContainerView
                    │
                    ▼
7. FilterView renders inside the modal's own NavigationStack
   (can push internally or present nested modals)
```

### Dismiss Chain

When code inside a modal calls `navigator.dismiss()`:

1. The modal's `NavigationCoordinator` checks: do I have a `fullScreenCover`? → close it
2. Do I have a `sheet`? → close it
3. No modals of my own? → call `onDismiss()` → nils the **parent's** modal state → SwiftUI dismisses this modal

### Navigation Infrastructure (AppKit)

| Component | Responsibility |
|-----------|---------------|
| `NavigationContainerView` | Reusable `NavigationStack` + push destinations + `.sheet`/`.fullScreenCover` bindings |
| `ModalContainerView` | Creates its own `NavigationCoordinator`, delegates to `NavigationContainerView` |
| `RootContainerView` | Uses `NavigationContainerView` + `.onOpenURL` for deep links |
