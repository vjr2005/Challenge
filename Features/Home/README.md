# ChallengeHome

Feature module for the home/dashboard screen of the application.

## Overview

ChallengeHome provides the main entry point screen for the application. It serves as the dashboard from which users can navigate to other features.

## Structure

```
Home/
├── Sources/
│   ├── HomeFeature.swift              # Feature entry point
│   ├── HomeContainer.swift            # DI container
│   ├── Navigation/
│   │   ├── HomeNavigation.swift
│   │   └── HomeDeepLinkHandler.swift
│   └── Presentation/
│       └── Home/
│           ├── Views/
│           │   └── HomeView.swift
│           ├── ViewModels/
│           │   ├── HomeViewModel.swift
│           │   └── HomeViewModelContract.swift
│           └── Navigator/
│               ├── HomeNavigator.swift
│               └── HomeNavigatorContract.swift
└── Tests/
    └── ...
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeHome` | Framework | Feature implementation |
| `ChallengeHomeTests` | Test | Unit and snapshot tests |

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Navigation, routing |
| `ChallengeResources` | Localized strings |

## Architecture

### Presentation Layer

**Home Screen:**
- `HomeView` - SwiftUI view displaying the dashboard
- `HomeViewModel` - Manages home screen state and user interactions
- `HomeNavigator` - Handles navigation to other features

## Navigation

### HomeNavigation

```swift
public enum HomeNavigation: Navigation {
    case main
}
```

### Deep Links

| URL | Destination |
|-----|-------------|
| `challenge://home` | Home screen |

## Usage

### Initialization

```swift
let feature = HomeFeature()
feature.registerDeepLinks()
```

### Creating the Home View

```swift
let homeView = feature.makeHomeView(router: router)
```

### Navigation

```swift
// Navigate to home
router.navigate(to: HomeNavigation.main)

// Via deep link
router.navigate(to: URL(string: "challenge://home"))
```

## Testing

### Test Organization

```
Tests/
├── Presentation/
│   └── Home/
│       ├── ViewModels/
│       │   └── HomeViewModelTests.swift
│       └── Snapshots/
│           └── HomeViewSnapshotTests.swift
├── Navigation/
│   ├── HomeDeepLinkHandlerTests.swift
│   └── HomeNavigatorTests.swift
├── Mocks/
│   └── HomeNavigatorMock.swift
├── Stubs/
│   └── HomeViewModelStub.swift
└── Feature/
    └── HomeFeatureTests.swift
```

### Running Tests

```bash
tuist test ChallengeHome
```

## Key Responsibilities

1. **Entry Point**: Serves as the initial screen after app launch
2. **Navigation Hub**: Provides access to other features (Characters, etc.)
3. **Dashboard**: Displays summary information or quick actions
4. **Deep Link Target**: Handles `challenge://home` deep links
