# ChallengeSystem

Feature module for system-level screens (Not Found, Error states).

## Overview

ChallengeSystem provides fallback screens for navigation errors and unknown routes. It serves as the catch-all for unhandled navigation destinations.

## Structure

```
System/
├── Sources/
│   ├── SystemFeature.swift
│   ├── SystemContainer.swift
│   └── Presentation/
│       └── NotFound/
│           ├── Views/
│           │   └── NotFoundView.swift
│           ├── ViewModels/
│           │   ├── NotFoundViewModel.swift
│           │   └── NotFoundViewModelContract.swift
│           └── Navigator/
│               ├── NotFoundNavigator.swift
│               └── NotFoundNavigatorContract.swift
└── Tests/
    └── ...
```

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `ChallengeSystem` | Framework | Feature implementation |
| `ChallengeSystemTests` | Test | Unit tests |
| `ChallengeSystemSnapshotTests` | Test | Snapshot tests |

## Dependencies

| Module | Purpose |
|--------|---------|
| `ChallengeCore` | Navigation |
| `ChallengeResources` | Localization |
| `ChallengeDesignSystem` | UI components |

## Usage

### Initialization

```swift
let feature = SystemFeature()
```

### As Fallback

`SystemFeature` is used by `AppContainer` as the fallback when no feature can handle a navigation:

```swift
func resolve(_ navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView {
    for feature in features {
        if let view = feature.resolve(navigation, navigator: navigator) {
            return view
        }
    }
    // Fallback to SystemFeature
    return systemFeature.makeMainView(navigator: navigator)
}
```

## Testing

```bash
tuist test ChallengeSystem
```
