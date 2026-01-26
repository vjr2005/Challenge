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
  - `ruby` 3.3 - Ruby runtime (for Fastlane)
  - `tuist` 4.129.0 - Project generation
  - `swiftlint` 0.63.1 - Code linting
  - `periphery` 3.4.0 - Dead code detection
- Install **Bundler** and Ruby gems (Fastlane)

### 2. Build the Project

Generate the Xcode project and install dependencies:

```bash
bundle exec fastlane build
```

### 3. Open in Xcode

After building, open the generated project:

```bash
open Challenge.xcodeproj
```

## Scripts

| Script | Description |
|--------|-------------|
| `./setup.sh` | Initial setup - installs brew, mise, project tools, and Ruby gems |
| `Scripts/run_swiftlint.sh` | Runs SwiftLint on the codebase (Xcode build phase) |

### Clean Build

To perform a clean build from scratch:

```bash
bundle exec fastlane clean
bundle exec fastlane build
```

## Fastlane

The project uses [Fastlane](https://fastlane.tools/) for CI/CD automation. Configuration is in the `fastlane/` directory.

### Available Lanes

**Atomic lanes** (single responsibility):

| Lane | Description | Command |
|------|-------------|---------|
| `install` | Install SPM dependencies | `bundle exec fastlane install` |
| `generate` | Generate Xcode project | `bundle exec fastlane generate` |
| `lint` | Run SwiftLint | `bundle exec fastlane lint` |
| `detect_dead_code` | Run Periphery dead code detection | `bundle exec fastlane detect_dead_code` |
| `execute_tests` | Execute unit tests | `bundle exec fastlane execute_tests` |
| `clean` | Clean Tuist cache and generated project | `bundle exec fastlane clean` |

**Composite lane** (CI entry point):

| Lane | Description | Command |
|------|-------------|---------|
| `ci` | install + generate + execute_tests + detect_dead_code | `bundle exec fastlane ci` |

## Continuous Integration

The project uses [GitHub Actions](https://github.com/features/actions) to run quality checks on every pull request targeting `main`.

### Workflow Overview

The CI workflow (`.github/workflows/ci.yml`) runs a single job on `macos-15` with the following steps:

| Step | Description |
|------|-------------|
| Checkout | Clone the repository |
| Select Xcode 26 | Use the latest Xcode 26.x available on the runner |
| Install mise tools | Install tuist, swiftlint, and periphery via mise (cached) |
| Install Fastlane | `bundle install` with vendored gems (cached) |
| Install SPM dependencies | `bundle exec fastlane install` (cached) |
| Generate Xcode project | `bundle exec fastlane generate` |
| Run tests | `bundle exec fastlane execute_tests` (includes SwiftLint as build phase) |
| Detect dead code | `bundle exec fastlane detect_dead_code` (informational, never blocks CI) |
| Comment PR | Posts Periphery results as a PR comment |

### Periphery PR Comments

Periphery runs with `continue-on-error: true` so it never blocks the pipeline. After execution, the workflow parses the output and posts a comment on the PR with:

- A table of unused code occurrences (file, line, description)
- The full Periphery output in a collapsible section
- If no issues are found, a success message

Successive pushes update the same comment instead of creating duplicates.

### GitHub Configuration

After pushing the workflow file, configure the repository:

#### 1. Workflow Permissions (required for private repos)

1. Go to **Settings** > **Actions** > **General**
2. Under **Workflow permissions**, select **Read and write permissions**
3. Save

#### 2. Branch Ruleset

1. Go to **Settings** > **Rules** > **Rulesets**
2. Click **New ruleset** > **New branch ruleset**
3. Configure:

| Field | Value |
|-------|-------|
| Ruleset name | `Protect main` |
| Enforcement status | `Active` |
| Target branches | **Add a target** > **Include default branch** |

4. Enable the following rules:

| Rule | Setting |
|------|---------|
| **Restrict deletions** | Enabled |
| **Require a pull request before merging** | Enabled |
| -- Required approvals | `1` |
| -- Dismiss stale approvals on new commits | Enabled |
| -- Require conversation resolution | Enabled |
| **Require status checks to pass** | Enabled |
| -- Status check | `Build & Test` (type the name and click **+**) |
| -- Require branches to be up to date | Enabled |
| **Block force pushes** | Enabled |

5. Click **Create**

> **Note:** The `Build & Test` status check will only appear after the workflow has run at least once. Create a test PR to trigger the first execution before configuring the ruleset.

### Design Decisions

- **Single job**: All steps run in one macOS job to minimize runner overhead. macOS minutes are billed at 10x in private repos.
- **Concurrency group**: Concurrent runs on the same branch are cancelled automatically, saving CI minutes.
- **Separate lanes**: Individual Fastlane lanes are used instead of the composite `ci` lane to allow `continue-on-error` on Periphery and capture its output for PR comments.

## Tools (mise)

This project uses [mise](https://mise.jdx.dev/) as a tool version manager. All tool versions are defined in `.mise.toml`:

| Tool | Version | Description |
|------|---------|-------------|
| **[Ruby](https://www.ruby-lang.org/)** | 3.3 | Ruby runtime (for Fastlane) |
| **[Tuist](https://tuist.io/)** | 4.129.0 | Xcode project generation and dependency management |
| **[SwiftLint](https://github.com/realm/SwiftLint)** | 0.63.1 | Swift style and conventions linter |
| **[Periphery](https://github.com/peripheryapp/periphery)** | 3.4.0 | Dead code detection for Swift |

### Ruby Gems (via Bundler)

| Gem | Purpose |
|-----|---------|
| **[Fastlane](https://fastlane.tools/)** | CI/CD automation |

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

### SOLID Principles

The codebase adheres to SOLID principles to ensure maintainable, extensible, and testable code:

| Principle | Description | Example in Codebase |
|-----------|-------------|---------------------|
| **S**ingle Responsibility | Each class/struct has only one reason to change | `GetCharactersUseCase` only handles fetching characters; `CharacterViewModel` only manages character list state |
| **O**pen/Closed | Open for extension, closed for modification | Protocols like `CharacterRepositoryContract` allow new implementations without modifying existing code |
| **L**iskov Substitution | Subtypes must be substitutable for their base types | `RemoteCharacterDataSource` and `MemoryCharacterDataSource` are interchangeable via `CharacterDataSourceContract` |
| **I**nterface Segregation | Prefer small, specific protocols over large ones | Separate contracts for `CharacterRepositoryContract`, `CharacterDataSourceContract` instead of one large protocol |
| **D**ependency Inversion | Depend on abstractions, not concrete implementations | ViewModels depend on UseCase protocols; Repositories depend on DataSource protocols |

#### Practical Application

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Dependency Inversion                               │
│                                                                             │
│   ViewModel ──► UseCaseContract ◄── UseCase ──► RepositoryContract ◄── Repo │
│                   (Protocol)                      (Protocol)                │
│                                                                             │
│   High-level modules depend on abstractions, not concrete implementations   │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Benefits:**
- **Testability**: Mock any layer by implementing its protocol
- **Flexibility**: Swap implementations (e.g., remote vs. memory data source) without changing dependent code
- **Maintainability**: Changes in one layer don't ripple through the entire codebase

## Project Structure

```
Challenge/
├── .github/
│   └── workflows/
│       └── ci.yml                # GitHub Actions CI workflow
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
├── fastlane/
│   └── Fastfile                  # CI/CD lane definitions
├── Project.swift
├── Tuist.swift
├── Gemfile                       # Ruby dependencies (Fastlane)
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
