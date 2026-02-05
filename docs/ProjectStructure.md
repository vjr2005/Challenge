# Project Structure

```
Challenge/
├── .github/
│   └── workflows/
│       └── quality-checks.yml  # GitHub Actions CI workflow
├── App/                             # Main application target
│   ├── Sources/
│   └── Tests/
│       ├── Shared/                  # Robots, Scenarios, Stubs, Fixtures
│       └── UI/                      # UI tests (XCTest)
├── AppKit/                          # Composition layer
│   ├── Sources/
│   │   ├── Data/                    # App-level data configuration
│   │   └── Presentation/            # Root views and navigation
│   └── Tests/
│       ├── Unit/
│       └── Snapshots/
├── Features/                        # Feature modules
│   ├── Character/
│   │   ├── Sources/
│   │   └── Tests/
│   ├── Home/
│   │   ├── Sources/
│   │   └── Tests/
│   └── System/
│       ├── Sources/
│       └── Tests/
├── Libraries/                       # Shared libraries
│   ├── Core/                        # Navigation, routing, image loading
│   │   ├── Sources/
│   │   ├── Tests/
│   │   └── Mocks/
│   ├── Networking/                  # HTTP client
│   │   ├── Sources/
│   │   ├── Tests/
│   │   └── Mocks/
│   └── DesignSystem/                # UI components (Atomic Design)
│       ├── Sources/
│       └── Tests/
├── Shared/
│   └── Resources/                   # Localization, shared resources
│       └── Sources/
├── Tuist/
│   ├── ProjectDescriptionHelpers/
│   │   └── Modules/
│   └── Package.swift
├── Scripts/
├── docs/
├── Project.swift
├── Tuist.swift
└── .mise.toml
```

## Modules

### App

Main application entry point.

| Target | Purpose |
|--------|---------|
| `Challenge` | Main app |
| `ChallengeTests` | UI tests |

### AppKit

Composition layer that wires all features together.

| Target | Purpose |
|--------|---------|
| `ChallengeAppKit` | Root views, navigation, dependency wiring |
| `ChallengeAppKitTests` | Unit tests |

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
| **ChallengeHome** | Home screen with logo animation |
| **ChallengeSystem** | System settings and configuration |

## Dependency Graph

```
Challenge (App)
└── ChallengeAppKit
    ├── ChallengeCore
    ├── ChallengeNetworking
    ├── ChallengeCharacter
    │   ├── ChallengeCore
    │   ├── ChallengeNetworking
    │   ├── ChallengeResources
    │   └── ChallengeDesignSystem
    ├── ChallengeHome
    │   ├── ChallengeCore
    │   ├── ChallengeResources
    │   ├── ChallengeDesignSystem
    │   └── Lottie (external)
    └── ChallengeSystem
        ├── ChallengeCore
        ├── ChallengeResources
        └── ChallengeDesignSystem

Libraries (base dependencies):
├── ChallengeCore (no dependencies)
├── ChallengeNetworking (no dependencies)
├── ChallengeResources → ChallengeCore
└── ChallengeDesignSystem → ChallengeCore
```
