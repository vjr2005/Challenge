# ChallengeCharacter

Feature module for displaying character information from the Rick and Morty API.

## Overview

ChallengeCharacter implements the character listing and detail screens following Clean Architecture with MVVM presentation layer. It demonstrates the full feature implementation pattern including data sources, repositories, use cases, and view models.

## Structure

```
Character/
├── Sources/
│   ├── CharacterFeature.swift         # Feature entry point
│   ├── CharacterContainer.swift       # DI container
│   ├── Navigation/
│   │   ├── CharacterNavigation.swift
│   │   └── CharacterDeepLinkHandler.swift
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Character.swift
│   │   │   ├── Location.swift
│   │   │   └── CharactersPage.swift
│   │   ├── Repositories/
│   │   │   └── CharacterRepositoryContract.swift
│   │   └── UseCases/
│   │       ├── GetCharactersUseCase.swift
│   │       └── GetCharacterUseCase.swift
│   ├── Data/
│   │   ├── Repositories/
│   │   │   └── CharacterRepository.swift
│   │   ├── DataSources/
│   │   │   ├── CharacterRemoteDataSource.swift
│   │   │   └── CharacterMemoryDataSource.swift
│   │   └── DTOs/
│   │       ├── CharacterDTO.swift
│   │       ├── CharactersResponseDTO.swift
│   │       └── LocationDTO.swift
│   └── Presentation/
│       ├── CharacterList/
│       │   ├── Views/
│       │   │   └── CharacterListView.swift
│       │   ├── ViewModels/
│       │   │   ├── CharacterListViewModel.swift
│       │   │   ├── CharacterListViewModelContract.swift
│       │   │   └── CharacterListViewState.swift
│       │   └── Navigator/
│       │       ├── CharacterListNavigator.swift
│       │       └── CharacterListNavigatorContract.swift
│       └── CharacterDetail/
│           ├── Views/
│           │   └── CharacterDetailView.swift
│           ├── ViewModels/
│           │   ├── CharacterDetailViewModel.swift
│           │   ├── CharacterDetailViewModelContract.swift
│           │   └── CharacterDetailViewState.swift
│           └── Navigator/
│               ├── CharacterDetailNavigator.swift
│               └── CharacterDetailNavigatorContract.swift
└── Tests/
    └── ...
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeCharacter` | Framework | Feature implementation |
| `ChallengeCharacterTests` | Test | Unit and snapshot tests |

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Navigation, routing, image loading |
| `ChallengeNetworking` | HTTP client for API requests |
| `ChallengeResources` | Localized strings |
| `ChallengeDesignSystem` | UI components |

## Architecture

### Domain Layer

**Models:**
- `Character` - Domain model representing a character
- `Location` - Character's location information
- `CharactersPage` - Paginated list of characters

**Use Cases:**
- `GetCharactersUseCase` - Fetches paginated character list
- `GetCharacterUseCase` - Fetches single character by ID

### Data Layer

**Repository:**
- `CharacterRepository` - Coordinates remote and memory data sources

**Data Sources:**
- `CharacterRemoteDataSource` - Fetches from Rick and Morty API
- `CharacterMemoryDataSource` - In-memory cache

**DTOs:**
- `CharacterDTO` - API response model
- `CharactersResponseDTO` - Paginated API response
- `LocationDTO` - Location API model

### Presentation Layer

**Character List:**
- `CharacterListView` - SwiftUI view for character grid
- `CharacterListViewModel` - Manages list state and pagination
- `CharacterListNavigator` - Handles navigation from list

**Character Detail:**
- `CharacterDetailView` - SwiftUI view for character details
- `CharacterDetailViewModel` - Manages detail state
- `CharacterDetailNavigator` - Handles navigation from detail

## Navigation

### CharacterNavigation

```swift
public enum CharacterNavigation: IncomingNavigationContract {
    case list
    case detail(identifier: Int)
}
```

### Deep Links

| URL | Destination |
|-----|-------------|
| `challenge://characters` | Character list |
| `challenge://characters/{id}` | Character detail |

## Usage

### Initialization

```swift
let feature = CharacterFeature(httpClient: httpClient)
feature.registerDeepLinks()
```

### Navigation

```swift
// Navigate to list
router.navigate(to: CharacterNavigation.list)

// Navigate to detail
router.navigate(to: CharacterNavigation.detail(identifier: 1))

// Via deep link
router.navigate(to: URL(string: "challenge://characters/1"))
```

## Testing

### Test Organization

```
Tests/
├── Domain/
│   ├── UseCases/           # Use case tests
│   └── Models/             # Model tests
├── Data/
│   ├── CharacterRepositoryTests.swift
│   ├── CharacterRemoteDataSourceTests.swift
│   └── CharacterMemoryDataSourceTests.swift
├── Presentation/
│   ├── CharacterList/
│   │   ├── ViewModels/     # ViewModel tests
│   │   └── Snapshots/      # Visual regression tests
│   └── CharacterDetail/
│       ├── ViewModels/
│       └── Snapshots/
├── Navigation/
│   └── CharacterDeepLinkHandlerTests.swift
├── Mocks/                  # Test doubles
├── Stubs/                  # Domain model stubs
└── Fixtures/               # JSON test data
```

### Running Tests

```bash
tuist test ChallengeCharacter
```

## API Reference

This feature uses the [Rick and Morty API](https://rickandmortyapi.com/):

| Endpoint | Description |
|----------|-------------|
| `GET /character` | List characters with pagination |
| `GET /character/{id}` | Get character by ID |
