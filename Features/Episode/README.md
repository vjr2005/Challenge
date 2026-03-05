# ChallengeEpisode

Feature module for displaying character episodes from the Rick and Morty API.

## Overview

ChallengeEpisode implements the character episodes screen following Clean Architecture with MVVM presentation layer. It uses GraphQL for data fetching and in-memory caching for offline support.

## Default Actor Isolation

| Setting | Value |
|---------|-------|
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` (project default) |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` |

All types are **MainActor-isolated by default** — no explicit `@MainActor` needed. Types that must run off the main thread opt out with `nonisolated`.

## Structure

```
Episode/
├── Sources/
│   ├── EpisodeFeature.swift
│   ├── EpisodeContainer.swift
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Episode.swift
│   │   │   ├── EpisodeCharacter.swift
│   │   │   └── EpisodeCharacterWithEpisodes.swift
│   │   ├── Repositories/
│   │   │   └── EpisodeRepositoryContract.swift
│   │   ├── UseCases/
│   │   │   ├── GetCharacterEpisodesUseCase.swift
│   │   │   └── RefreshCharacterEpisodesUseCase.swift
│   │   └── Errors/
│   │       └── EpisodeError.swift
│   ├── Data/
│   │   ├── Mappers/
│   │   │   ├── EpisodeMapper.swift
│   │   │   ├── EpisodeCharacterMapper.swift
│   │   │   ├── EpisodeCharacterWithEpisodesMapper.swift
│   │   │   └── EpisodeErrorMapper.swift
│   │   ├── Repositories/
│   │   │   └── EpisodeRepository.swift
│   │   ├── DataSources/
│   │   │   ├── Remote/
│   │   │   │   ├── EpisodeRemoteDataSourceContract.swift
│   │   │   │   └── EpisodeGraphQLDataSource.swift
│   │   │   └── Local/
│   │   │       ├── EpisodeLocalDataSourceContract.swift
│   │   │       └── EpisodeMemoryDataSource.swift
│   │   └── DTOs/
│   │       ├── EpisodeDTO.swift
│   │       ├── EpisodeCharacterDTO.swift
│   │       └── EpisodeCharacterWithEpisodesDTO.swift
│   └── Presentation/
│       ├── Navigation/
│       │   ├── EpisodeIncomingNavigation.swift
│       │   ├── EpisodeOutgoingNavigation.swift
│       │   └── EpisodeDeepLinkHandler.swift
│       └── CharacterEpisodes/
│           ├── Views/
│           │   └── CharacterEpisodesView.swift
│           ├── ViewModels/
│           │   ├── CharacterEpisodesViewModel.swift
│           │   ├── CharacterEpisodesViewModelContract.swift
│           │   └── CharacterEpisodesViewState.swift
│           ├── Navigator/
│           │   ├── CharacterEpisodesNavigator.swift
│           │   └── CharacterEpisodesNavigatorContract.swift
│           └── Tracker/
│               ├── CharacterEpisodesTracker.swift
│               ├── CharacterEpisodesTrackerContract.swift
│               └── CharacterEpisodesEvent.swift
└── Tests/
    └── ...
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeEpisode` | Framework | Feature implementation |
| `ChallengeEpisodeTests` | Test | Unit tests |
| `ChallengeEpisodeSnapshotTests` | Test | Snapshot tests |

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Navigation, image loading |
| `ChallengeNetworking` | GraphQL client |
| `ChallengeResources` | Localization |
| `ChallengeDesignSystem` | UI components |

## Navigation

### EpisodeIncomingNavigation

```swift
public enum EpisodeIncomingNavigation: IncomingNavigationContract {
    case characterEpisodes(characterIdentifier: Int)
}
```

### EpisodeOutgoingNavigation

```swift
public enum EpisodeOutgoingNavigation: OutgoingNavigationContract {
    case characterDetail(identifier: Int)
}
```

Outgoing navigation allows navigating from an episode's character list to the character detail screen in the Character module.

### Deep Links

| URL | Destination |
|-----|-------------|
| `challenge://episode/character/{id}` | Character episodes |

## Usage

### Initialization

```swift
let feature = EpisodeFeature(httpClient: httpClient, tracker: tracker)
```

### Navigation

```swift
navigator.navigate(to: EpisodeIncomingNavigation.characterEpisodes(characterIdentifier: 1))
```

## API

Uses the [Rick and Morty GraphQL API](https://rickandmortyapi.com/graphql):

| Operation | Description |
|-----------|-------------|
| `GetEpisodesByCharacter` | Fetch all episodes for a character, including episode details and appearing characters |

## Testing

```bash
xcodebuild test \
  -workspace Challenge.xcworkspace \
  -scheme "Challenge (Dev)" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1'
```
