# Tuist Configuration

The project uses [Tuist](https://tuist.io/) for Xcode project generation and dependency management.

## Project Structure

```
Tuist/
├── ProjectDescriptionHelpers/
│   ├── Config.swift                          # App name, Swift version, deployment target
│   ├── MainApp.swift                         # Global mainApp instance
│   ├── Environment.swift                     # Environment-specific settings (Dev/Staging/Prod)
│   ├── ExternalPackages.swift                # External SPM package definitions
│   ├── ModuleKit/                            # Core module infrastructure
│   │   ├── ProjectConfig.swift               # Shared project configuration
│   │   ├── BuildConfiguration.swift          # Debug/Release configurations
│   │   ├── SwiftLint.swift                   # SwiftLint build phase integration
│   │   ├── WorkspaceRoot.swift               # Workspace root path helpers
│   │   ├── App.swift                         # App project, targets, schemes, coverage
│   │   ├── Strategy/                         # Module integration strategies
│   │   │   ├── ActiveStrategy.swift          # typealias Module = FrameworkModule or SPMModule
│   │   │   ├── ModuleContract.swift          # Protocol defining module behavior
│   │   │   ├── FrameworkModule.swift          # Framework target strategy
│   │   │   ├── SPMModule.swift               # SPM local package strategy
│   │   │   ├── ModuleDependency.swift        # Dependency specification types
│   │   │   ├── ModuleFileSystem.swift        # File system detection for modules
│   │   │   ├── ModuleAggregation.swift       # Aggregates test actions and coverage
│   │   │   └── ExternalPackage.swift         # External package wrapper
│   │   └── Generators/                       # Manifest-time code generation
│   │       ├── PackageSwiftGenerator.swift   # Auto-generates Package.swift for SPM modules
│   │       └── TestPlanGenerator.swift       # Auto-generates test plans for SPM modules
│   └── Modules/                              # Individual module instantiations
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
└── Package.swift                             # External SPM dependencies + PackageSettings
```

## Key Settings

```swift
// ProjectConfig.swift
appName = "Challenge"
swiftToolsVersion = "6.2"
iosMajorVersion = "17"
destinations = [.iPhone, .iPad]
```

## Module Strategy Pattern

The project uses a **Strategy Pattern** for module integration. A global `typealias Module` in `ActiveStrategy.swift` selects the active strategy for **all** modules:

```swift
// ActiveStrategy.swift
public typealias Module = FrameworkModule  // or SPMModule
```

| Strategy | Description |
|----------|-------------|
| `FrameworkModule` | Modules as framework targets in the root project (current) |
| `SPMModule` | Modules as SPM local packages with auto-generated `Package.swift` |

**Tuist 4.x limitation:** All modules must use the same strategy — mixing is not supported.

Each module is a global constant instantiated with `Module(...)`:

```swift
// Tuist/ProjectDescriptionHelpers/Modules/CharacterModule.swift
public let characterModule = Module(
    directory: "Features/Character",
    dependencies: [
        .module(coreModule),
        .module(networkingModule),
        .module(resourcesModule),
        .module(designSystemModule),
    ],
    testDependencies: [
        .moduleMocks(coreModule),
        .moduleMocks(networkingModule),
    ],
    snapshotTestDependencies: [
        .module(snapshotTestKitModule),
        .moduleMocks(coreModule),
        .moduleMocks(networkingModule),
    ]
)
```

### Module Dependencies

Modules declare dependencies using the `ModuleDependency` enum:

| Case | Usage | Description |
|------|-------|-------------|
| `.module(someModule)` | `dependencies`, `snapshotTestDependencies` | Source target of another module |
| `.moduleMocks(someModule)` | `testDependencies`, `snapshotTestDependencies` | Mocks target of another module |
| `.external(somePackage)` | `dependencies` | External SPM package |

### FrameworkModule Strategy (Current)

Each `FrameworkModule` generates the following targets in the root project:

1. **Source** (e.g., `ChallengeCharacter`) — framework with production code
2. **Mocks** (e.g., `ChallengeCharacterMocks`) — framework with public mocks (if `Mocks/` exists)
3. **Unit Tests** (e.g., `ChallengeCharacterTests`) — unit test bundle (if `Tests/Unit/` exists)
4. **Snapshot Tests** (e.g., `ChallengeCharacterSnapshotTests`) — unit test bundle (if `Tests/Snapshots/` exists)

### SPMModule Strategy (Alternative)

Each `SPMModule` auto-generates a `Package.swift` (via `PackageSwiftGenerator`) with:
- `.library()` products (source + mocks)
- A single `.testTarget` merging unit and snapshot tests
- Dependencies resolved via relative `path:` references

## External Packages

All external SPM dependencies are centralized in `ExternalPackages.swift`:

| Package | Product | Version | Product Type |
|---------|---------|---------|--------------|
| swift-snapshot-testing | SnapshotTesting | 1.17.0 | .framework |
| lottie-ios | Lottie | 4.6.0 | .framework |
| SwiftMockServer | SwiftMockServerBinary | 1.1.1 | .framework |

`Tuist/Package.swift` uses `#if TUIST` to derive dependencies and settings from `allExternalPackages`. The `#else` branch has a hardcoded fallback for `tuist install` (pure SPM mode).

### Adding an External Package

1. Define in `ExternalPackages.swift`:

```swift
public let newPackage = ExternalPackage(
    productName: "PackageName",
    url: "https://github.com/owner/repo",
    version: "1.0.0",
    productType: .framework
)
```

2. Add to `allExternalPackages` array
3. Add to `Package.swift` `#else` fallback block (keep in sync)
4. Use in module: `.external(newPackage)`

## App and Project

The root `Project.swift` delegates to `mainApp.project`:

```swift
let project = mainApp.project
```

`App.swift` aggregates all module data into a single `Project`:
- **Targets**: app + UI tests + all module framework targets
- **Schemes**: per-environment (Dev/Staging/Prod) + UI tests + per-module schemes
- **Packages**: aggregated from modules (empty for FrameworkModule, populated for SPMModule)
- **Test action**: `ModuleAggregation` selects `.targets(...)` or `.testPlans(...)` based on strategy
- **Coverage**: `ModuleAggregation` selects `.targets(...)` or `.relevant` based on strategy

The `mainApp` instance is defined in `MainApp.swift` with all 10 modules and `appKitModule` as entry point.

### Adding a New Module

1. Create the module directory with `Sources/` (and optionally `Mocks/`, `Tests/Unit/`, `Tests/Snapshots/`)
2. Create `Tuist/ProjectDescriptionHelpers/Modules/{Name}Module.swift`
3. Add the module to the `modules` array in `MainApp.swift`

`ModuleFileSystem` auto-detects folder structure — no manual target configuration needed.

## Swift 6 Concurrency

The project uses strict Swift 6 concurrency with MainActor isolation by default:

```swift
// ProjectConfig.swift — baseSettings (shared across all targets)
"SWIFT_VERSION": "6.2"
"SWIFT_APPROACHABLE_CONCURRENCY": "YES"
"SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor"
```

### Per-Module Overrides

Modules can override settings via `settingsOverrides`:

```swift
// NetworkingModule.swift — nonisolated default for data layer types
public let networkingModule = Module(
    directory: "Libraries/Networking",
    dependencies: [.module(coreModule)],
    settingsOverrides: [
        "SWIFT_DEFAULT_ACTOR_ISOLATION": .string("nonisolated"),
    ]
)
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

## Auto-Generation System

The project includes manifest-time generators that support both module strategies:

### PackageSwiftGenerator

Called from `SPMModule.init()` during manifest evaluation. Auto-creates `Package.swift` for each SPM module with proper targets, dependencies, and Swift settings (MainActor or nonisolated isolation).

### TestPlanGenerator

Called from `ModuleAggregation.aggregateTestAction()` when SPM modules are present. Creates an `.xctestplan` file aggregating all module test targets with code coverage configuration.

Both generators execute at manifest-time (`tuist generate`), not build-time.

## Testing

Module tests use `xcodebuild test` with the `Challenge (Dev)` scheme. The test action adapts based on the active module strategy:

**FrameworkModule (current):** Uses `.targets(...)` directly.

```bash
# Run all module tests (unit + snapshot)
xcodebuild test \
  -workspace Challenge.xcworkspace \
  -scheme "Challenge (Dev)" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

**SPMModule (if switched):** Uses `.testPlans(...)` with an auto-generated test plan.

```bash
# Run all module tests (unit + snapshot) — SPM strategy
xcodebuild test \
  -workspace Challenge.xcworkspace \
  -scheme "Challenge (Dev)" \
  -testPlan Challenge \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

UI tests always use Tuist:

```bash
# Run UI tests
mise x -- tuist test "ChallengeUITests"
```

Always use `xcodebuild test` for module tests (not `tuist test`).

## Commands

```bash
# Install SPM dependencies
mise x -- tuist install

# Generate Xcode project
mise x -- tuist generate

# Build the project
mise x -- tuist build

# Run module tests (unit + snapshot)
xcodebuild test \
  -workspace Challenge.xcworkspace \
  -scheme "Challenge (Dev)" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'

# Run UI tests
mise x -- tuist test "ChallengeUITests"

# Clean and regenerate
mise x -- tuist clean && mise x -- tuist generate
```

## Derived Folder

Tuist generates files in the `Derived/` folder:

```
Derived/
└── InfoPlists/
    ├── Challenge-Info.plist
    └── ChallengeUITests-Info.plist
```

**Contents:** Only `Info.plist` files for the app and UI tests targets.

**Git:** The `Derived/` folder is in `.gitignore`.

## Adding an XCFramework as a Dependency

### 1. XCFramework Location

Place the `.xcframework` file in the `Tuist/Dependencies/` directory:

```
Challenge/
├── Tuist/
│   ├── Dependencies/
│   │   └── FrameworkName.xcframework
│   └── ProjectDescriptionHelpers/
├── Libraries/
├── App/
└── Project.swift
```

> **Note:** The `Tuist/Dependencies/` directory is ignored by git. Do not commit xcframeworks to the repository.

### 2. Create the XCFrameworks Helper

If it doesn't exist, create the file `Tuist/ProjectDescriptionHelpers/Dependencies.swift`:

```swift
import ProjectDescription

public enum XCFrameworks {
  public static let frameworkName: TargetDependency = .xcframework(path: "Tuist/Dependencies/FrameworkName.xcframework")
}
```

### 3. Add the Dependency to a Module

Use `.external()` or add directly to the module's dependencies:

```swift
public let myModule = Module(
    directory: "Features/MyFeature",
    dependencies: [
        .module(coreModule),
        // XCFramework dependency would go in the target directly
    ]
)
```

### 4. Regenerate the Project

```bash
./generate.sh
```
