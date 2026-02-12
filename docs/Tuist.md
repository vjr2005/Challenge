# Tuist Configuration

The project uses [Tuist](https://tuist.io/) for Xcode project generation and dependency management.

## Project Structure

```
Tuist/
├── ProjectDescriptionHelpers/
│   ├── Config.swift              # App name, Swift version, deployment target
│   ├── Modules.swift             # Module registry and app dependencies
│   ├── FrameworkModule.swift     # Module definition helper
│   ├── BuildConfiguration.swift  # Debug/Release configurations
│   ├── Environment.swift         # Environment-specific settings (Dev/Staging/Prod)
│   ├── AppScheme.swift           # Xcode scheme generation
│   ├── SwiftLint.swift           # SwiftLint build phase integration
│   └── Modules/                  # Individual module definitions
│       ├── CoreModule.swift
│       ├── NetworkingModule.swift
│       ├── ResourcesModule.swift
│       ├── DesignSystemModule.swift
│       ├── CharacterModule.swift
│       ├── HomeModule.swift
│       ├── EpisodeModule.swift
│       ├── SystemModule.swift
│       ├── SnapshotTestKitModule.swift
│       └── AppKitModule.swift
└── Package.swift                 # SPM dependencies
```

## Key Settings

```swift
// Config.swift
appName = "Challenge"
swiftVersion = "6.0"
developmentTarget = .iOS("17.0")
destinations = [.iPhone, .iPad]
```

## Swift 6 Concurrency

The project uses strict Swift 6 concurrency with MainActor isolation by default:

```swift
// Project.swift base settings
"SWIFT_VERSION": "6.0"
"SWIFT_APPROACHABLE_CONCURRENCY": "YES"
"SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor"
```

## Build Configurations

| Configuration | Type | Compilation Conditions |
|---------------|------|------------------------|
| Debug | Debug | `DEBUG` |
| Debug-Staging | Debug | `DEBUG DEBUG_STAGING` |
| Debug-Prod | Debug | `DEBUG DEBUG_PROD` |
| Staging | Release | `STAGING` |
| Release | Release | `PRODUCTION` |

## Environments

The app supports three environments (Development, Staging, Production) with different bundle IDs and app icons. See [Environments.md](Environments.md) for full documentation including icons, API configuration, and usage.

## AppKit - Composition Layer

The `ChallengeAppKit` module exists as a **composition layer** between the App target and the feature modules.

```
Challenge (App)
    │
    └── ChallengeAppKit (Composition Layer)
            │
            ├── ChallengeCharacter
            ├── ChallengeEpisode
            ├── ChallengeHome
            ├── ChallengeSystem
            ├── ChallengeCore
            └── ChallengeNetworking
```

### Why a Separate Target?

1. **Maximize App Independence**: The App target only depends on AppKit, keeping `App/Sources/` minimal (just the entry point)

2. **Testability**: All composition logic (dependency injection, navigation, root views) can be unit tested without running the full app

3. **Faster Iteration**: Changes to AppKit don't require recompiling the App target during development

4. **Clear Boundaries**: Separates "what the app does" (AppKit) from "how it launches" (App)

### AppKit Responsibilities

| Responsibility | Description |
|----------------|-------------|
| Dependency Injection | Creates and wires all dependencies (DataSources, Repositories, UseCases) |
| Root Navigation | Manages the app's navigation stack and deep linking |
| Feature Composition | Combines features into the final user experience |
| Environment Configuration | Configures API URLs and other environment-specific settings |

## Module Types

The project separates modules into two categories: **Libraries** and **Features**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FEATURES (Vertical)                            │
│    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│    │  Character  │    │    Home     │    │   System    │                    │
│    ├─────────────┤    ├─────────────┤    ├─────────────┤                    │
│    │ Presentation│    │ Presentation│    │ Presentation│                    │
│    │   Domain    │    │   Domain    │    │   Domain    │                    │
│    │    Data     │    │    Data     │    │    Data     │                    │
│    └─────────────┘    └─────────────┘    └─────────────┘                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            LIBRARIES (Horizontal)                           │
│  ┌──────────┐  ┌────────────┐  ┌──────────────┐  ┌───────────┐              │
│  │   Core   │  │ Networking │  │ DesignSystem │  │ Resources │              │
│  └──────────┘  └────────────┘  └──────────────┘  └───────────┘              │
│         Agnostic - No business logic - Shared across all features           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Libraries (Horizontal)

Libraries are **horizontal modules** that provide shared infrastructure. They are:

- **Agnostic**: No knowledge of business domain or features
- **Reusable**: Can be used by any feature without modification
- **Stable**: Rarely change, providing a solid foundation

| Library | Purpose |
|---------|---------|
| `ChallengeCore` | Navigation, routing, deep linking, image loading, environment |
| `ChallengeNetworking` | HTTP client (REST) and GraphQL client, request/response handling |
| `ChallengeDesignSystem` | UI components, design tokens, atomic design |
| `ChallengeResources` | Localization, shared assets |

### Features (Vertical)

Features are **vertical slices** that contain all layers for a specific domain:

- **Self-contained**: Each feature has its own Presentation, Domain, and Data layers
- **Independent**: Features don't depend on each other
- **Domain-specific**: Contains business logic for one bounded context

| Feature | Domain |
|---------|--------|
| `ChallengeCharacter` | Character list and detail (Rick & Morty REST API) |
| `ChallengeEpisode` | Character episodes (Rick & Morty GraphQL API) |
| `ChallengeHome` | Home screen with logo animation |
| `ChallengeSystem` | System settings and configuration |

### Dependency Rules

```
Features ──► Libraries    ✅ Allowed
Features ──► Features     ❌ Forbidden
Libraries ──► Libraries   ✅ Allowed (with care)
Libraries ──► Features    ❌ Forbidden
```

This ensures features remain independent and can be developed, tested, and potentially extracted as separate modules.

## Module Definition

Modules are defined using `FrameworkModule.create()` which automatically:

- Creates the framework target
- Creates a Mocks target (if `Mocks/` folder exists)
- Creates Unit Tests target (if `Tests/Unit/` folder exists)
- Creates Snapshot Tests target (if `Tests/Snapshots/` folder exists)
- Includes shared test resources from `Tests/Shared/`
- Adds SwiftLint build phase
- Configures code coverage

### Example Module

```swift
public enum CharacterModule {
    public static let module = FrameworkModule.create(
        name: "Character",
        baseFolder: "Features",
        path: "Character",
        dependencies: [
            .target(name: "\(appName)Core"),
            .target(name: "\(appName)Networking"),
            .target(name: "\(appName)Resources"),
            .target(name: "\(appName)DesignSystem"),
        ],
        testDependencies: [
            .target(name: "\(appName)CoreMocks"),
            .target(name: "\(appName)NetworkingMocks"),
        ],
        snapshotTestDependencies: [
            .target(name: "\(appName)CoreMocks"),
            .target(name: "\(appName)NetworkingMocks"),
        ]
    )
}
```

## Commands

```bash
# Install SPM dependencies
mise x -- tuist install

# Generate Xcode project
mise x -- tuist generate

# Build the project
mise x -- tuist build

# Run tests
mise x -- tuist test

# Clean and regenerate
mise x -- tuist clean && mise x -- tuist generate
```
