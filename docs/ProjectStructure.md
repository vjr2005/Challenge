# Project Structure

```
Challenge/
├── .github/
│   └── workflows/
│       └── ci.yml                # GitHub Actions CI workflow
├── App/                          # Main application target
│   ├── Sources/
│   ├── Tests/
│   └── UITests/
├── Features/                     # Feature modules
│   ├── Character/
│   └── Home/
├── Libraries/                    # Shared libraries
│   ├── Core/                     # Navigation, routing, image loading
│   ├── Networking/               # HTTP client
│   └── DesignSystem/             # UI components (Atomic Design)
├── Shared/
│   └── Resources/                # Localization, shared resources
├── Tuist/
│   ├── ProjectDescriptionHelpers/
│   └── Package.swift
├── Scripts/
├── Project.swift
├── Tuist.swift
└── .mise.toml
```

## Modules

### App

Main application entry point with dependency injection container.

| Target | Purpose |
|--------|---------|
| `Challenge` | Main app |
| `ChallengeTests` | Unit tests |
| `ChallengeUITests` | UI tests |

### Libraries

| Module | Purpose |
|--------|---------|
| **ChallengeCore** | Navigation, routing, deep linking, image loading, app environment |
| **ChallengeNetworking** | HTTP client abstraction over URLSession |
| **ChallengeDesignSystem** | Atomic Design UI components and design tokens |
| **ChallengeResources** | Localization and shared resources |

### Features

| Module | Purpose |
|--------|---------|
| **ChallengeCharacter** | Character list and detail screens |
| **ChallengeHome** | Home/dashboard screen |

## Dependency Graph

```
Challenge (App)
├── ChallengeCore
├── ChallengeCharacter
│   ├── ChallengeCore
│   ├── ChallengeNetworking
│   ├── ChallengeResources
│   └── ChallengeDesignSystem
│       └── ChallengeCore
└── ChallengeHome
    ├── ChallengeCore
    └── ChallengeResources
        └── ChallengeCore
```
