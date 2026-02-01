# Architecture

The project follows **MVVM + Clean Architecture** with feature-based modularization.

## Overview

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

## Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| **Presentation** | UI components, ViewModels with state management, navigation |
| **Domain** | Business logic (UseCases), domain models, repository contracts |
| **Data** | Repository implementations, data sources (remote/memory), DTOs |

## SOLID Principles

The codebase adheres to SOLID principles to ensure maintainable, extensible, and testable code:

| Principle | Description | Example in Codebase |
|-----------|-------------|---------------------|
| **S**ingle Responsibility | Each class/struct has only one reason to change | `GetCharactersUseCase` only handles fetching characters; `CharacterViewModel` only manages character list state |
| **O**pen/Closed | Open for extension, closed for modification | Protocols like `CharacterRepositoryContract` allow new implementations without modifying existing code |
| **L**iskov Substitution | Subtypes must be substitutable for their base types | `RemoteCharacterDataSource` and `MemoryCharacterDataSource` are interchangeable via `CharacterDataSourceContract` |
| **I**nterface Segregation | Prefer small, specific protocols over large ones | Separate contracts for `CharacterRepositoryContract`, `CharacterDataSourceContract` instead of one large protocol |
| **D**ependency Inversion | Depend on abstractions, not concrete implementations | ViewModels depend on UseCase protocols; Repositories depend on DataSource protocols |

### Practical Application

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

### Benefits

- **Testability**: Mock any layer by implementing its protocol
- **Flexibility**: Swap implementations (e.g., remote vs. memory data source) without changing dependent code
- **Maintainability**: Changes in one layer don't ripple through the entire codebase
