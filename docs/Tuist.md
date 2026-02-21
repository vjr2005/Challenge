# Tuist Configuration

The project uses [Tuist](https://tuist.io/) for Xcode project generation and dependency management.

## Project Structure

```
Tuist/
├── ProjectDescriptionHelpers/
│   ├── Config.swift              # App name, Swift version, deployment target, workspaceRoot
│   ├── Modules.swift             # Central module registry (array + derived properties)
│   ├── App.swift                 # App project, targets, references, dependencies, coverage
│   ├── Module.swift              # Module definition and factory
│   ├── BuildConfiguration.swift  # Debug/Release configurations
│   ├── Environment.swift         # Environment-specific settings (Dev/Staging/Prod)
│   ├── AppScheme.swift           # App scheme generation (per-environment + UI tests)
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
swiftVersion = "6.2"
developmentTarget = .iOS("17.0")
destinations = [.iPhone, .iPad]
```

## Modules

All modules are **SPM local packages** with their own `Package.swift`. Each package defines `.library()` products (source + mocks) and a single `.testTarget` combining all test sources. The root project references them via `packages: Modules.packageReferences`.

Each module is a global `Module` constant with the following properties:

| Property | Type | Purpose |
|----------|------|---------|
| `targetDependency` | `TargetDependency` | `.package(product: name)` for consuming targets |
| `mocksTargetDependency` | `TargetDependency` | `.package(product: "\(name)Mocks")` for mock dependencies |
| `packageReference` | `Package` | `.package(path: directory)` for the project packages array |

## App, Modules, and AppScheme

Three enums with clear responsibilities and a unidirectional dependency chain:

```
AppScheme → App → Modules
```

| Enum | File | Responsibility |
|------|------|----------------|
| `Modules` | `Modules.swift` | Central module registry (`all` array) with derived `packageReferences` |
| `App` | `App.swift` | App project definition (targets, packages, schemes), references (`targetReference`, `uiTestsTargetReference`) |
| `AppScheme` | `AppScheme.swift` | Scheme factory — creates environment, UI test, and module test schemes |

The root `Project.swift` is: `let project = App.project`. It includes the app target, UI tests target, and all module packages.

### Adding a New Module

**3 steps** needed:

1. Create the module's `Package.swift` (source, mocks, tests targets with proper dependencies)
2. Create module definition in `Tuist/ProjectDescriptionHelpers/Modules/{Feature}Module.swift`
3. Add the module to `Modules.all` in `Modules.swift`

Additionally, add the module's test target to `Challenge.xctestplan` and its target settings to `Tuist/Package.swift`.

## Swift 6 Concurrency

The project uses strict Swift 6 concurrency with MainActor isolation by default:

```swift
// Config.swift — projectBaseSettings (shared across all targets)
"SWIFT_VERSION": "6.2"
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

Each module has its own `Package.swift` that defines source, mocks, and test targets. The Tuist `Module.create()` factory creates a metadata holder that auto-detects the Mocks folder:

### Example Module Definition (Tuist)

```swift
// Tuist/ProjectDescriptionHelpers/Modules/CharacterModule.swift
public let characterModule = Module.create(directory: "Features/Character")
```

### Example Package.swift (SPM)

```swift
// Features/Character/Package.swift
let package = Package(
    name: "ChallengeCharacter",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ChallengeCharacter", targets: ["ChallengeCharacter"]),
    ],
    dependencies: [
        .package(path: "../../Libraries/Core"),
        .package(path: "../../Libraries/Networking"),
        // ...
    ],
    targets: [
        .target(name: "ChallengeCharacter", dependencies: [...], path: "Sources"),
        .testTarget(name: "ChallengeCharacterTests", dependencies: [...], path: "Tests"),
    ]
)
```

Cross-module dependencies use relative `path:` references. SPM package identity uses the **directory name** (last path component), not the `name:` field.

### Build Settings

Per-target build settings are configured in `Tuist/Package.swift` via `targetSettings`:

```swift
// Tuist/Package.swift
targetSettings: [
    "ChallengeCore": .settings(base: projectBaseSettings),
    "ChallengeNetworking": .settings(base: projectBaseSettings.merging([
        "SWIFT_DEFAULT_ACTOR_ISOLATION": .string("nonisolated"),
    ]) { _, new in new }),
    "ChallengeSnapshotTestKit": .settings(base: projectBaseSettings.merging([
        "ENABLE_TESTING_SEARCH_PATHS": "YES",
    ]) { _, new in new }),
]
```

The Networking module overrides the project-wide `MainActor` default to `nonisolated` because all Networking types are pure data structures or stateless services with no UI concerns.

## Testing

Module tests run via `xcodebuild` using the `Challenge.xctestplan` test plan, which aggregates all 8 module test targets. Tuist's `tuist test` command does not support test plan schemes.

```bash
# Generate project first
mise x -- tuist generate

# Run all module tests (unit + snapshot)
xcodebuild test \
  -workspace Challenge.xcworkspace \
  -scheme ChallengeModuleTests \
  -testPlan Challenge \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=latest"

# Run UI tests (still uses tuist test)
mise x -- tuist test "ChallengeUITests"
```

The `ChallengeModuleTests` scheme uses `.testPlans(["Challenge.xctestplan"])` which references test targets by container path and identifier. This is necessary because SPM package test targets cannot be referenced via Tuist's `.target()` scheme API.

## Commands

```bash
# Install SPM dependencies
mise x -- tuist install

# Generate Xcode project
mise x -- tuist generate

# Build the project
mise x -- tuist build

# Run module tests (unit + snapshot)
mise x -- tuist generate && xcodebuild test \
  -workspace Challenge.xcworkspace \
  -scheme ChallengeModuleTests \
  -testPlan Challenge \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=latest"

# Run UI tests
mise x -- tuist test "ChallengeUITests"

# Clean and regenerate
mise x -- tuist clean && mise x -- tuist generate
```
