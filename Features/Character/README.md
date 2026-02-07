# ChallengeCharacter

Feature module for displaying character information from the Rick and Morty API.

## Overview

ChallengeCharacter implements the character listing and detail screens following Clean Architecture with MVVM presentation layer.

## Structure

```
Character/
├── Sources/
│   ├── CharacterFeature.swift
│   ├── CharacterContainer.swift
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Character.swift
│   │   │   ├── CharacterLocation.swift
│   │   │   └── CharactersPage.swift
│   │   ├── Repositories/
│   │   │   ├── CharacterRepositoryContract.swift
│   │   │   └── CharactersPageRepositoryContract.swift
│   │   ├── UseCases/
│   │   │   ├── GetCharacterDetailUseCase.swift
│   │   │   ├── GetCharactersPageUseCase.swift
│   │   │   ├── RefreshCharacterDetailUseCase.swift
│   │   │   ├── RefreshCharactersPageUseCase.swift
│   │   │   └── SearchCharactersPageUseCase.swift
│   │   └── Errors/
│   │       ├── CharacterError.swift
│   │       └── CharactersPageError.swift
│   ├── Data/
│   │   ├── Repositories/
│   │   │   ├── CharacterRepository.swift
│   │   │   ├── CharactersPageRepository.swift
│   │   │   └── CharacterDTOMapping.swift
│   │   ├── DataSources/
│   │   │   ├── CharacterRemoteDataSource.swift
│   │   │   └── CharacterMemoryDataSource.swift
│   │   └── DTOs/
│   │       ├── CharacterDTO.swift
│   │       ├── CharactersResponseDTO.swift
│   │       └── LocationDTO.swift
│   └── Presentation/
│       ├── Navigation/
│       │   ├── CharacterIncomingNavigation.swift
│       │   └── CharacterDeepLinkHandler.swift
│       ├── CharacterList/
│       │   ├── Views/
│       │   │   └── CharacterListView.swift
│       │   ├── ViewModels/
│       │   │   ├── CharacterListViewModel.swift
│       │   │   ├── CharacterListViewModelContract.swift
│       │   │   └── CharacterListViewState.swift
│       │   ├── Navigator/
│       │   │   ├── CharacterListNavigator.swift
│       │   │   └── CharacterListNavigatorContract.swift
│       │   └── Tracker/
│       │       ├── CharacterListTracker.swift
│       │       ├── CharacterListTrackerContract.swift
│       │       └── CharacterListEvent.swift
│       └── CharacterDetail/
│           ├── Views/
│           │   └── CharacterDetailView.swift
│           ├── ViewModels/
│           │   ├── CharacterDetailViewModel.swift
│           │   ├── CharacterDetailViewModelContract.swift
│           │   └── CharacterDetailViewState.swift
│           ├── Navigator/
│           │   ├── CharacterDetailNavigator.swift
│           │   └── CharacterDetailNavigatorContract.swift
│           └── Tracker/
│               ├── CharacterDetailTracker.swift
│               ├── CharacterDetailTrackerContract.swift
│               └── CharacterDetailEvent.swift
└── Tests/
    └── ...
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeCharacter` | Framework | Feature implementation |
| `ChallengeCharacterTests` | Test | Unit tests |
| `ChallengeCharacterSnapshotTests` | Test | Snapshot tests |

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Navigation, image loading |
| `ChallengeNetworking` | HTTP client |
| `ChallengeResources` | Localization |
| `ChallengeDesignSystem` | UI components |

## Navigation

### CharacterIncomingNavigation

```swift
public enum CharacterIncomingNavigation: IncomingNavigationContract {
    case list
    case detail(identifier: Int)
}
```

### Deep Links

| URL | Destination |
|-----|-------------|
| `challenge://character/list` | Character list |
| `challenge://character/detail?id=1` | Character detail |

## Usage

### Initialization

```swift
let feature = CharacterFeature(httpClient: httpClient, tracker: tracker)
```

### Navigation

```swift
navigator.navigate(to: CharacterIncomingNavigation.list)
navigator.navigate(to: CharacterIncomingNavigation.detail(identifier: 1))
```

## API

Uses the [Rick and Morty API](https://rickandmortyapi.com/):

| Endpoint | Description |
|----------|-------------|
| `GET /character` | List characters with pagination |
| `GET /character/{id}` | Get character by ID |
| `GET /character?name=` | Search characters by name |

## Testing

```bash
tuist test ChallengeCharacter
```
