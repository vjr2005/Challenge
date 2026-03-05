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
├── AppKit/                          # Composition layer (SPM local package)
│   ├── Package.swift
│   ├── Sources/
│   │   ├── Data/                    # App-level data configuration
│   │   └── Presentation/            # Root views and navigation
│   └── Tests/
│       ├── Unit/
│       └── Snapshots/
├── Features/                        # Feature modules (SPM local packages)
│   ├── Character/
│   │   ├── Package.swift
│   │   ├── Sources/
│   │   └── Tests/
│   ├── Home/
│   │   ├── Package.swift
│   │   ├── Sources/
│   │   └── Tests/
│   ├── Episode/
│   │   ├── Package.swift
│   │   ├── Sources/
│   │   └── Tests/
│   └── System/
│       ├── Package.swift
│       ├── Sources/
│       └── Tests/
├── Libraries/                       # Shared libraries (SPM local packages)
│   ├── Core/                        # Navigation, routing, image loading
│   │   ├── Package.swift
│   │   ├── Sources/
│   │   ├── Tests/
│   │   └── Mocks/
│   ├── Networking/                  # HTTP client
│   │   ├── Package.swift
│   │   ├── Sources/
│   │   ├── Tests/
│   │   └── Mocks/
│   ├── DesignSystem/                # UI components (Atomic Design)
│   │   ├── Package.swift
│   │   ├── Sources/
│   │   └── Tests/
│   └── SnapshotTestKit/             # Snapshot testing framework
│       ├── Package.swift
│       └── Sources/
├── Shared/
│   └── Resources/                   # Localization, shared resources
│       ├── Package.swift
│       └── Sources/
├── Tuist/
│   ├── ProjectDescriptionHelpers/
│   │   └── Modules/
│   └── Package.swift               # External SPM dependencies + target settings
├── Scripts/
├── docs/
├── Project.swift                    # Root project (app + UI tests + module packages)
├── Workspace.swift                  # Workspace configuration (code coverage)
├── Challenge.xctestplan            # Test plan aggregating all module test targets (SPM strategy only)
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
| **ChallengeSnapshotTestKit** | Snapshot testing helpers (test-only, wraps swift-snapshot-testing) |

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
└── ChallengeSnapshotTestKit (test-only, wraps swift-snapshot-testing)
```
