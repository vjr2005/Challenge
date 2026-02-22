# Project Structure

```
Challenge/
├── .github/
│   ├── actions/
│   │   ├── setup/              # Composite action: Xcode, mise, caching, SPM, simulator
│   │   └── test-report/        # Composite action: artifact upload, summary, PR comment
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
│   ├── Episode/
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
│   ├── DesignSystem/                # UI components (Atomic Design)
│   │   ├── Sources/
│   │   └── Tests/
│   └── SnapshotTestKit/             # Snapshot testing framework
│       └── Sources/
├── Shared/
│   └── Resources/                   # Localization, shared resources
│       └── Sources/
├── Tuist/
│   ├── ProjectDescriptionHelpers/
│   │   └── Modules/
│   └── Package.swift
├── Scripts/
├── docs/
├── Project.swift                    # Root project (app + UI tests)
├── Workspace.swift                  # Workspace (includes all module projects, hosts app schemes)
├── Tuist.swift
└── .mise.toml
```

## Modules

### App

Main application entry point.

| Target | Purpose |
|--------|---------|
| `Challenge` | Main app |
| `ChallengeUITests` | UI tests |

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
| **ChallengeNetworking** | HTTP client (REST) and GraphQL client abstraction over URLSession |
| **ChallengeDesignSystem** | Atomic Design UI components and design tokens |
| **ChallengeResources** | Localization and shared resources |
| **ChallengeSnapshotTestKit** | Snapshot testing framework (test-only) |

### Features

| Module | Purpose |
|--------|---------|
| **ChallengeCharacter** | Character list and detail screens (Rick & Morty REST API) |
| **ChallengeEpisode** | Character episodes list (Rick & Morty GraphQL API) |
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
    ├── ChallengeEpisode
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
├── ChallengeDesignSystem → ChallengeCore
└── ChallengeSnapshotTestKit (test-only, auto-linked to snapshot test targets)
```
