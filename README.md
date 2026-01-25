# Challenge

iOS application built with **Swift 6**, **SwiftUI**, and **Clean Architecture**.

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 26+ |
| iOS | 17.0+ |
| Swift | 6.2 |
| macOS | Sequoia 15.6+ |

## Quick Start

### 1. Initial Setup

Run the setup script to install all required tools:

```bash
./setup.sh
```

This script will:
- Install **Homebrew** (if not installed)
- Install **mise** (tool version manager)
- Configure mise activation in your shell
- Install project tools from `.mise.toml`:
  - `tuist` 4.129.0 - Project generation
  - `swiftlint` 0.63.1 - Code linting
  - `periphery` 3.4.0 - Dead code detection

### 2. Build the Project

Generate the Xcode project and install dependencies:

```bash
./build.sh
```

This script runs:
1. `tuist install` - Install SPM dependencies
2. `tuist generate` - Generate Xcode project

### 3. Open in Xcode

After building, open the generated project:

```bash
open Challenge.xcodeproj
```

## Scripts

| Script | Description |
|--------|-------------|
| `./setup.sh` | Initial setup - installs brew, mise, and project tools |
| `./build.sh` | Installs dependencies and generates Xcode project |
| `./clean.sh` | Cleans Tuist cache and removes generated project files |
| `Scripts/run_swiftlint.sh` | Runs SwiftLint on the codebase |

### Clean Build

To perform a clean build from scratch:

```bash
./clean.sh && ./build.sh
```

## Tools (mise)

This project uses [mise](https://mise.jdx.dev/) as a tool version manager. All tool versions are defined in `.mise.toml`:

| Tool | Version | Description |
|------|---------|-------------|
| **[Tuist](https://tuist.io/)** | 4.129.0 | Xcode project generation and dependency management |
| **[SwiftLint](https://github.com/realm/SwiftLint)** | 0.63.1 | Swift style and conventions linter |
| **[Periphery](https://github.com/peripheryapp/periphery)** | 3.4.0 | Dead code detection for Swift |

## Architecture

The project follows **MVVM + Clean Architecture** with feature-based modularization.

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                    Presentation Layer                       │
                    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
                    │  │    View     │  │  ViewModel  │  │     Navigator       │  │
                    │  │  (SwiftUI)  │◄─┤ @Observable │──┤ (NavigatorContract) │  │
                    │  └─────────────┘  └─────────────┘  └─────────────────────┘  │
                    └─────────────────────────────────────────────────────────────┘
                                                │
                                                ▼
                    ┌─────────────────────────────────────────────────────────────┐
                    │                      Domain Layer                           │
                    │  ┌─────────────────────┐  ┌─────────────────────────────┐   │
                    │  │      Use Case       │  │         Models              │   │
                    │  │  (Business Logic)   │  │    (Domain Models)          │   │
                    │  └─────────────────────┘  └─────────────────────────────┘   │
                    └─────────────────────────────────────────────────────────────┘
                                                │
                                                ▼
                    ┌─────────────────────────────────────────────────────────────┐
                    │                       Data Layer                            │
                    │  ┌─────────────────────┐  ┌─────────────────────────────┐   │
                    │  │     Repository      │  │       Data Source           │   │
                    │  │  (Implementation)   │  │   (Remote/Memory)           │   │
                    │  └─────────────────────┘  └─────────────────────────────┘   │
                    └─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| **Presentation** | UI components, ViewModels with state management, navigation |
| **Domain** | Business logic (UseCases), domain models, repository contracts |
| **Data** | Repository implementations, data sources (remote/memory), DTOs |

## Project Structure

```
Challenge/
├── App/                          # Main application target
│   ├── Sources/
│   ├── Tests/
│   └── E2ETests/
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
| `ChallengeE2ETests` | End-to-end UI tests |

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

### Dependency Graph

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

## Tuist Configuration

The project uses **Tuist** for project generation with helpers in `Tuist/ProjectDescriptionHelpers/`:

| File | Purpose |
|------|---------|
| `Config.swift` | Global configuration (app name, Swift version, deployment target) |
| `Modules.swift` | Module registry and dependencies |
| `FrameworkModule.swift` | Module definition helper |
| `BuildConfiguration.swift` | Debug/Release configurations |
| `Environment.swift` | Environment-specific settings |
| `AppScheme.swift` | Xcode scheme generation |
| `SwiftLint.swift` | SwiftLint build phase integration |

### Key Settings

```swift
// Config.swift
appName = "Challenge"
swiftVersion = "6.0"
developmentTarget = .iOS("17.0")
destinations = [.iPhone, .iPad]
```

### Swift 6 Concurrency

The project uses strict Swift 6 concurrency with:

```swift
"SWIFT_APPROACHABLE_CONCURRENCY": "YES"
"SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor"
```

## Testing

### Test Types

| Type | Framework | Location |
|------|-----------|----------|
| Unit Tests | Swift Testing | `*/Tests/` |
| Snapshot Tests | SnapshotTesting | `*/Tests/Snapshots/` |
| E2E Tests | XCTest | `App/E2ETests/` |

### Test Structure

Tests follow Given/When/Then structure:

```swift
@Test
func fetchesCharacters() async throws {
    // Given
    let sut = GetCharactersUseCase(repository: repositoryMock)

    // When
    let result = try await sut.execute(page: 1)

    // Then
    #expect(result.characters.count == 2)
}
```

## Deep Linking

The app supports URL-based deep links with the `challenge://` scheme:

| URL | Destination |
|-----|-------------|
| `challenge://home` | Home screen |
| `challenge://characters` | Character list |
| `challenge://characters/{id}` | Character detail |

## External Dependencies

| Package | Purpose |
|---------|---------|
| [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) | Visual regression testing |

**Policy:** Prefer native implementations. External dependencies only when strictly necessary.

## Documentation

Each module has its own README with detailed documentation:

- [App](App/README.md)
- [ChallengeCore](Libraries/Core/README.md)
- [ChallengeNetworking](Libraries/Networking/README.md)
- [ChallengeDesignSystem](Libraries/DesignSystem/README.md)
- [ChallengeResources](Shared/Resources/README.md)
- [ChallengeCharacter](Features/Character/README.md)
- [ChallengeHome](Features/Home/README.md)

## CLAUDE.md

See [CLAUDE.md](CLAUDE.md) for detailed coding standards, architecture patterns, and development practices.
