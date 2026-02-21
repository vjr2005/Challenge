# ChallengeCharacter

Feature module for displaying character information from the Rick and Morty API.

## Overview

ChallengeCharacter implements the character listing and detail screens following Clean Architecture with MVVM presentation layer.

## Default Actor Isolation

| Setting | Value |
|---------|-------|
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` (project default) |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` |

All types are **MainActor-isolated by default** — no explicit `@MainActor` needed. Types that must run off the main thread opt out with `nonisolated`.

## Structure

```
Character/
├── Sources/
│   ├── CharacterFeature.swift
│   ├── CharacterContainer.swift
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Character.swift
│   │   │   ├── CharacterFilter.swift
│   │   │   ├── CharactersPage.swift
│   │   │   └── Location.swift
│   │   ├── Repositories/
│   │   │   ├── CharacterRepositoryContract.swift
│   │   │   ├── CharactersPageRepositoryContract.swift
│   │   │   └── RecentSearchesRepositoryContract.swift
│   │   ├── UseCases/
│   │   │   ├── GetCharacterUseCase.swift
│   │   │   ├── GetCharactersPageUseCase.swift
│   │   │   ├── RefreshCharacterUseCase.swift
│   │   │   ├── RefreshCharactersPageUseCase.swift
│   │   │   ├── SearchCharactersPageUseCase.swift
│   │   │   ├── GetRecentSearchesUseCase.swift
│   │   │   ├── SaveRecentSearchUseCase.swift
│   │   │   └── DeleteRecentSearchUseCase.swift
│   │   └── Errors/
│   │       ├── CharacterError.swift
│   │       └── CharactersPageError.swift
│   ├── Data/
│   │   ├── Mappers/
│   │   │   ├── LocationMapper.swift
│   │   │   ├── CharacterMapper.swift
│   │   │   ├── CharacterErrorMapper.swift
│   │   │   ├── CharacterFilterMapper.swift
│   │   │   ├── CharactersPageMapper.swift
│   │   │   └── CharactersPageErrorMapper.swift
│   │   ├── Repositories/
│   │   │   ├── CharacterRepository.swift
│   │   │   ├── CharactersPageRepository.swift
│   │   │   └── RecentSearchesRepository.swift
│   │   ├── DataSources/
│   │   │   ├── Remote/
│   │   │   │   ├── CharacterRemoteDataSourceContract.swift
│   │   │   │   └── CharacterRESTDataSource.swift
│   │   │   └── Local/
│   │   │       ├── CharacterLocalDataSourceContract.swift
│   │   │       ├── CharacterMemoryDataSource.swift
│   │   │       ├── RecentSearchesLocalDataSourceContract.swift
│   │   │       └── RecentSearchesUserDefaultsDataSource.swift
│   │   └── DTOs/
│   │       ├── CharacterDTO.swift
│   │       ├── CharacterFilterDTO.swift
│   │       ├── CharactersResponseDTO.swift
│   │       └── LocationDTO.swift
│   └── Presentation/
│       ├── Navigation/
│       │   ├── CharacterIncomingNavigation.swift
│       │   ├── CharacterOutgoingNavigation.swift
│       │   ├── CharacterFilterDelegate.swift
│       │   └── CharacterDeepLinkHandler.swift
│       ├── Shared/
│       │   └── CharacterEnums+Localized.swift
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
│       ├── CharacterDetail/
│       │   ├── Views/
│       │   │   └── CharacterDetailView.swift
│       │   ├── ViewModels/
│       │   │   ├── CharacterDetailViewModel.swift
│       │   │   ├── CharacterDetailViewModelContract.swift
│       │   │   └── CharacterDetailViewState.swift
│       │   ├── Navigator/
│       │   │   ├── CharacterDetailNavigator.swift
│       │   │   └── CharacterDetailNavigatorContract.swift
│       │   └── Tracker/
│       │       ├── CharacterDetailTracker.swift
│       │       ├── CharacterDetailTrackerContract.swift
│       │       └── CharacterDetailEvent.swift
│       └── CharacterFilter/
│           ├── Views/
│           │   └── CharacterFilterView.swift
│           ├── ViewModels/
│           │   ├── CharacterFilterViewModel.swift
│           │   └── CharacterFilterViewModelContract.swift
│           ├── Navigator/
│           │   ├── CharacterFilterNavigator.swift
│           │   └── CharacterFilterNavigatorContract.swift
│           └── Tracker/
│               ├── CharacterFilterTracker.swift
│               ├── CharacterFilterTrackerContract.swift
│               └── CharacterFilterEvent.swift
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
    case characterFilter(delegate: any CharacterFilterDelegate)
}
```

The `characterFilter` case carries a `CharacterFilterDelegate` reference, enabling direct communication between `CharacterListViewModel` (which conforms to the delegate) and `CharacterFilterViewModel`.

### Deep Links

| URL | Destination |
|-----|-------------|
| `challenge://character/list` | Character list |
| `challenge://character/detail/1` | Character detail |

## Usage

### Initialization

```swift
let feature = CharacterFeature(httpClient: httpClient, tracker: tracker, imageLoader: imageLoader)
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
mise x -- tuist test --skip-ui-tests
```
