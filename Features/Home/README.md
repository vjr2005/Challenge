# ChallengeHome

Feature module for the home screen of the application.

## Overview

ChallengeHome provides the main entry point screen. It serves as the dashboard from which users navigate to other features.

## Default Actor Isolation

| Setting | Value |
|---------|-------|
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` (project default) |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` |

All types are **MainActor-isolated by default** — no explicit `@MainActor` needed. Types that must run off the main thread opt out with `nonisolated`.

## Structure

```
Home/
├── Sources/
│   ├── HomeFeature.swift
│   ├── HomeContainer.swift
│   └── Presentation/
│       ├── Navigation/
│       │   ├── HomeIncomingNavigation.swift
│       │   ├── HomeOutgoingNavigation.swift
│       │   └── HomeDeepLinkHandler.swift
│       ├── Home/
│       │   ├── Views/
│       │   │   └── HomeView.swift
│       │   ├── ViewModels/
│       │   │   ├── HomeViewModel.swift
│       │   │   └── HomeViewModelContract.swift
│       │   ├── Navigator/
│       │   │   ├── HomeNavigator.swift
│       │   │   └── HomeNavigatorContract.swift
│       │   └── Tracker/
│       │       ├── HomeTracker.swift
│       │       ├── HomeTrackerContract.swift
│       │       └── HomeEvent.swift
│       └── About/
│           ├── Views/
│           │   └── AboutView.swift
│           ├── ViewModels/
│           │   ├── AboutViewModel.swift
│           │   └── AboutViewModelContract.swift
│           ├── Navigator/
│           │   ├── AboutNavigator.swift
│           │   └── AboutNavigatorContract.swift
│           └── Tracker/
│               ├── AboutTracker.swift
│               ├── AboutTrackerContract.swift
│               └── AboutEvent.swift
└── Tests/
    └── ...
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeHome` | Framework | Feature implementation |
| `ChallengeHomeTests` | Test | Unit tests |
| `ChallengeHomeSnapshotTests` | Test | Snapshot tests |

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Navigation |
| `ChallengeResources` | Localization |
| `ChallengeDesignSystem` | UI components |

## Navigation

### HomeIncomingNavigation

```swift
public enum HomeIncomingNavigation: IncomingNavigationContract {
    case main
    case about
}
```

### HomeOutgoingNavigation

```swift
public enum HomeOutgoingNavigation: OutgoingNavigationContract {
    case characters
}
```

### Deep Links

| URL | Destination |
|-----|-------------|
| `challenge://home/main` | Home screen |

## Usage

### Initialization

```swift
let feature = HomeFeature(tracker: tracker)
```

### Navigation

```swift
// Navigate to home
navigator.navigate(to: HomeIncomingNavigation.main)

// From home to characters (outgoing)
navigator.navigate(to: HomeOutgoingNavigation.characters)
```

## Testing

```bash
tuist test ChallengeHome
```
