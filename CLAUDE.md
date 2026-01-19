# Project Guidelines

This document defines the coding standards, architecture patterns, and development practices for this iOS project. All code and documentation must be written in **English**.

> **CRITICAL:** All generated code must compile without errors or warnings. Before writing code, carefully analyze for:
> - Unused variables, parameters, or imports
> - Missing protocol conformances
> - Type mismatches
> - Concurrency issues (Sendable, actor isolation)
> - **Never use force unwrap (`!`)** - use `guard let`, `if let`, or `try?` instead
>
> **After writing code, always verify compilation** by running `tuist test`.
>
> **All code must pass SwiftLint validation.**
>
> **Maximum test coverage is required.** When creating or modifying any component, all related changes must be fully tested.

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
| `/app-configuration` | Environments, build configs, schemes, API configuration |
| `/tuist` | Tuist configuration: xcframeworks, dependencies, Project.swift |
| `/datasource` | RemoteDataSource for APIs, MemoryDataSource for caching, DTOs |
| `/repository` | Repository pattern, DTO-to-Domain mapping, local-first caching |
| `/usecase` | UseCase pattern for business logic |
| `/viewmodel` | ViewModels with ViewState pattern |
| `/view` | SwiftUI Views, previews, accessibility identifiers |
| `/snapshot` | Snapshot tests with SnapshotTesting library |
| `/router` | Navigation with Router and RouterContract |
| `/dependencyInjection` | Containers, feature entry points, dependency wiring |

---

## Architecture Overview

This project follows **MVVM + Clean Architecture** with feature-based modularization.

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    View     │  │  ViewModel  │  │    Navigation       │  │
│  │  (SwiftUI)  │◄─┤ @Observable │  │  (RouterContract)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌─────────────────────┐  ┌─────────────────────────────┐   │
│  │      Use Case       │  │         Models              │   │
│  │  (Business Logic)   │  │    (Domain Models)          │   │
│  └─────────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌─────────────────────┐  ┌─────────────────────────────┐   │
│  │     Repository      │  │       Data Source           │   │
│  │  (Implementation)   │  │   (Remote/Memory)           │   │
│  └─────────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

For detailed patterns, see skills: `/view`, `/viewmodel`, `/usecase`, `/repository`, `/datasource`

---

## Swift 6 Concurrency

| Setting | Effect |
|---------|--------|
| `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` | All types MainActor-isolated by default |
| `SWIFT_APPROACHABLE_CONCURRENCY = YES` | Automatic Sendable inference |

**Key rules:**
- No `@MainActor` needed on ViewModels/Views (it's default)
- Use `actor` for background work (e.g., MemoryDataSource)
- Mark DTOs as `nonisolated` if used in actors
- No explicit `Sendable` conformance (it's inferred)

For details, see `/concurrency` skill.

---

## Dependencies

| Dependency | Purpose |
|------------|---------|
| SnapshotTesting | Snapshot tests (Point-Free) |
| SwiftLint | Code linting (via mise) |

**Policy:** Prefer native implementations. No external dependencies unless strictly necessary.

---

## Networking

Native networking layer using **URLSession with async/await**. No external dependencies.

**Location:** `Libraries/Networking/`

| Component | Description |
|-----------|-------------|
| `HTTPClientContract` | Protocol for HTTP client (enables DI) |
| `HTTPClient` | URLSession implementation |
| `Endpoint` | Request configuration |
| `HTTPError` | Error types |
| `HTTPClientMock` | Mock for testing |

For usage, see [Libraries/Networking/README.md](Libraries/Networking/README.md) and `/datasource` skill.

---

## Quick Reference

### Prohibited Patterns

```swift
DispatchQueue.main.async { }
DispatchQueue.global().async { }
completion: @escaping (Result<T, Error>) -> Void
ObservableObject / @Published  // Use @Observable
force unwrap (!)
```

### Required Patterns

```swift
async/await                    // For async code
@Observable                    // For state management (iOS 17+)
actor                          // For shared mutable state
protocols (contracts)          // For dependency injection
Contract suffix                // For protocols
Mock suffix                    // For mocks (suffix only, never prefix)
```

### Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Protocol | `{Name}Contract` | `UserRepositoryContract` |
| Mock | `{Name}Mock` | `UserRepositoryMock` |
| Mock variable | `{name}Mock` | `userRepositoryMock` |
| Parameter | `identifier` not `id` | `func get(identifier: Int)` |

For complete style guide, see `/style-guide` skill.

---

## Testing Quick Reference

| Rule | Description |
|------|-------------|
| SUT naming | Always name object under test as `sut` |
| Structure | Use `// Given`, `// When`, `// Then` comments |
| Assertions | Use `#expect`, `#require` for unwrapping |
| Comparison | Compare full objects, not individual properties |
| Mocks location | `Tests/Mocks/` (internal) or `Mocks/` (public) |
| Stubs location | `Tests/Stubs/` for Domain models |
| Fixtures location | `Tests/Fixtures/` for JSON (DTOs) |

For details, see `/testing` skill.

---

## Tuist

The project uses Tuist for project generation.

| File | Purpose |
|------|---------|
| `Project.swift` | Main project definition |
| `Tuist.swift` | Tuist configuration |
| `Tuist/ProjectDescriptionHelpers/` | Shared helpers |

For configuration details, see `/tuist` skill.
