# Project Guidelines

This document defines the coding standards, architecture patterns, and development practices for this iOS project. All code and documentation must be written in **English**.

> **CRITICAL:** Never create git commits without explicit user permission. Always wait for the user to request a commit.
>
> **CRITICAL:** All generated code must compile without errors or warnings. Before writing code, carefully analyze for:
> - Unused variables, parameters, or imports
> - Missing protocol conformances
> - Type mismatches
> - Concurrency issues (Sendable, actor isolation)
> - **Never use force unwrap (`!`)** - use `guard let`, `if let`, or `try?` instead
>
> **Before generating Swift code**, always consult the `/concurrency` and `/style-guide` skills to ensure compliance with project standards. **After generating code**, use the `/testing` skill to create corresponding tests.
>
> **After writing code, always verify compilation** by running `mise x -- tuist test`.
>
> **All code must pass SwiftLint validation.**
>
> **Maximum test coverage is required.** When creating or modifying any component, all related changes must be fully tested.
>
> **Code coherence is mandatory.** The same logic must be used to solve the same problem throughout the project. When refactoring or adding new code, analyze the entire project to identify similar patterns and ensure consistency. Never implement the same solution in different ways.
>
> **All code must follow SOLID principles:**
> - **S**ingle Responsibility: Each class/struct should have only one reason to change
> - **O**pen/Closed: Open for extension, closed for modification
> - **L**iskov Substitution: Subtypes must be substitutable for their base types
> - **I**nterface Segregation: Prefer small, specific protocols over large, general ones
> - **D**ependency Inversion: Depend on abstractions (protocols), not concrete implementations

---

## Skills Reference

Use these skills for detailed implementation patterns:

| Skill | Description |
|-------|-------------|
| `/concurrency` | Swift 6 concurrency: async/await, actors, MainActor, Sendable |
| `/style-guide` | Code formatting, naming conventions, SwiftLint rules |
| `/testing` | Unit testing patterns, Given/When/Then, parameterized tests |
| `/e2e-tests` | End-to-end UI tests with Robot pattern |
| `/project-structure` | Directory organization, feature modules, extensions |
| `/resources` | Resources module: localization, String extensions |
| `/tuist` | Tuist configuration: xcframeworks, dependencies, Project.swift |
| `/datasource` | RemoteDataSource for APIs, MemoryDataSource for caching, DTOs |
| `/repository` | Repository pattern, DTO-to-Domain mapping, local-first caching |
| `/usecase` | UseCase pattern for business logic |
| `/viewmodel` | ViewModels with ViewState pattern |
| `/view` | SwiftUI Views, previews, accessibility identifiers |
| `/snapshot` | Snapshot tests with SnapshotTesting library |
| `/router` | Navigation with Router, Navigator pattern, and Deep Links |
| `/dependencyInjection` | Containers, feature entry points, dependency wiring |
| `/clean-code` | Dead code detection and removal using Periphery |

---

## Architecture Overview

This project follows **MVVM + Clean Architecture** with feature-based modularization.

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

For detailed patterns, see skills: `/view`, `/viewmodel`, `/usecase`, `/repository`, `/datasource`

---

## Dependencies

### SPM Packages

| Package | Purpose |
|---------|---------|
| SnapshotTesting | Snapshot tests (Point-Free) |

### Tools (via mise)

| Tool | Purpose | Command |
|------|---------|---------|
| Tuist | Project generation | `mise x -- tuist` |
| SwiftLint | Code linting | `mise x -- swiftlint` |
| Periphery | Dead code detection | `mise x -- periphery scan` |

**Policy:** Prefer native implementations. No external dependencies unless strictly necessary.

---

## Testing Quick Reference

### Test Directory Structure

```
Module/Tests/
├── Unit/           → Unit tests (Swift Testing)
├── Snapshots/      → Snapshot tests (SnapshotTesting)
├── E2E/            → E2E tests (XCTest, App only)
└── Shared/         → Shared resources
    ├── Stubs/      → Domain model test data
    ├── Mocks/      → Internal test mocks
    ├── Fixtures/   → JSON files for DTOs
    ├── Extensions/ → Test helpers (Equatable, etc.)
    └── Resources/  → Test images
```

### Testing Rules

| Rule | Description |
|------|-------------|
| SUT naming | Always name object under test as `sut` |
| Structure | Use `// Given`, `// When`, `// Then` comments |
| Assertions | Use `#expect`, `#require` for unwrapping |
| Comparison | Compare full objects, not individual properties |
| Mocks location | `Tests/Shared/Mocks/` (internal) or `Mocks/` (public) |
| Stubs location | `Tests/Shared/Stubs/` for Domain models |
| Fixtures location | `Tests/Shared/Fixtures/` for JSON (DTOs) |
| Coverage scope | Only source targets (never mocks or external libraries) |
| Unit tests | Use Swift Testing (`@Test`, `#expect`) |
| Snapshot tests | Use SnapshotTesting library |
| E2E/UI tests | Use XCTest (`XCTestCase`, `XCUIApplication`) - required for UI testing |

For details, see `/testing` skill.

---

## Tuist

The project uses Tuist for project generation.

> **CRITICAL:** Always use the Tuist MCP server to query or modify Tuist configuration. Before making any changes to `Project.swift` or `ProjectDescriptionHelpers/`, first consult the project graph via MCP to understand the current structure and dependencies.

| File | Purpose |
|------|---------|
| `Project.swift` | Main project definition |
| `Tuist.swift` | Tuist configuration |
| `Tuist/ProjectDescriptionHelpers/` | Shared helpers |

For configuration details, see `/tuist` skill.
