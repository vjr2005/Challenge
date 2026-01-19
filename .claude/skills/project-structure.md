---
name: project-structure
autoContext: true
description: Project organization and directory structure. Use when creating features, organizing files, or understanding the codebase layout.
---

# Skill: Project Structure

Guide for project organization and directory structure.

## When to use this skill

- Create a new feature module
- Organize files correctly
- Understand the codebase layout
- Add extensions to existing types

---

## Project Overview

```
Challenge/
├── App/
│   ├── Sources/
│   │   ├── ChallengeApp.swift
│   │   └── Resources/
│   │       └── Assets.xcassets/
│   ├── Tests/
│   └── E2ETests/
├── Libraries/
│   ├── Core/
│   ├── Networking/
│   ├── AppConfiguration/
│   └── Features/
│       ├── User/
│       ├── Character/
│       └── Home/
├── Tuist/
│   └── ProjectDescriptionHelpers/
├── Project.swift
├── Tuist.swift
└── CLAUDE.md
```

---

## Feature Naming

Feature directory names must **not** contain the word "Feature". Use simple, descriptive names:

```
// RIGHT
Libraries/Features/User/
Libraries/Features/Character/
Libraries/Features/Home/

// WRONG
Libraries/Features/UserFeature/
Libraries/Features/CharacterFeature/
```

---

## Feature Module Structure

Each feature module follows this internal structure:

```
FeatureName/
├── Sources/
│   ├── {Feature}Feature.swift              # Public entry point
│   ├── {Feature}Navigation.swift           # Navigation destinations
│   ├── Container/
│   │   └── {Feature}Container.swift        # Dependency injection
│   ├── Domain/
│   │   ├── Models/
│   │   │   └── {Name}.swift                # Domain models
│   │   ├── UseCases/
│   │   │   └── Get{Name}UseCase.swift      # Business logic
│   │   └── Repositories/
│   │       └── {Name}RepositoryContract.swift  # Repository contracts
│   ├── Data/
│   │   ├── DataSources/
│   │   │   ├── {Name}RemoteDataSource.swift
│   │   │   └── {Name}MemoryDataSource.swift
│   │   ├── DTOs/
│   │   │   └── {Name}DTO.swift
│   │   └── Repositories/
│   │       └── {Name}Repository.swift
│   └── Presentation/
│       ├── {Name}List/
│       │   ├── Views/
│       │   │   └── {Name}ListView.swift
│       │   └── ViewModels/
│       │       ├── {Name}ListViewModel.swift
│       │       └── {Name}ListViewState.swift
│       └── {Name}Detail/
│           ├── Views/
│           │   └── {Name}DetailView.swift
│           └── ViewModels/
│               ├── {Name}DetailViewModel.swift
│               └── {Name}DetailViewState.swift
├── Tests/
│   ├── Domain/
│   │   └── UseCases/
│   │       └── Get{Name}UseCaseTests.swift
│   ├── Data/
│   │   └── {Name}RepositoryTests.swift
│   ├── Presentation/
│   │   └── {Name}List/
│   │       ├── ViewModels/
│   │       │   └── {Name}ListViewModelTests.swift
│   │       └── Snapshots/
│   │           └── {Name}ListViewSnapshotTests.swift
│   ├── Stubs/
│   │   └── {Name}+Stub.swift
│   ├── Fixtures/
│   │   └── {name}.json
│   └── Mocks/
│       ├── Get{Name}UseCaseMock.swift
│       └── {Name}RepositoryMock.swift
└── Mocks/                                   # Public mocks (if needed)
    └── {Name}RepositoryMock.swift
```

---

## Presentation Layer Organization

The Presentation layer groups related Views and ViewModels by feature name:

```
Presentation/
├── CharacterDetail/            # Feature: Character detail screen
│   ├── Views/
│   │   └── CharacterDetailView.swift
│   └── ViewModels/
│       ├── CharacterDetailViewModel.swift
│       └── CharacterDetailViewState.swift
├── CharacterList/              # Feature: Character list screen
│   ├── Views/
│   │   └── CharacterListView.swift
│   └── ViewModels/
│       ├── CharacterListViewModel.swift
│       └── CharacterListViewState.swift
└── ...
```

**Naming conventions:**
- Folder name matches the feature (e.g., `CharacterDetail`)
- View: `{FeatureName}View.swift`
- ViewModel: `{FeatureName}ViewModel.swift`
- ViewState: `{FeatureName}ViewState.swift`

---

## Extensions

Extensions of external framework types (Foundation, UIKit, SwiftUI, etc.) must be placed in an `Extensions/` folder.

### Location

```
Sources/
├── Extensions/
│   ├── URL+QueryItems.swift
│   ├── Date+Formatting.swift
│   └── String+Validation.swift
└── ...

Tests/
├── Extensions/
│   ├── URLSession+Mock.swift
│   ├── HTTPURLResponse+Mock.swift
│   └── URLRequest+BodyData.swift
└── ...
```

### Naming Convention

**Pattern:** `TypeName+Purpose.swift`

```swift
// URL+QueryItems.swift
extension URL {
    func appendingQueryItems(_ items: [URLQueryItem]) -> URL { ... }
}

// URLSession+Mock.swift (in Tests)
extension URLSession {
    static func mockSession() -> URLSession { ... }
}

// Date+Formatting.swift
extension Date {
    func formatted(style: DateFormatter.Style) -> String { ... }
}
```

---

## Tests Directory Structure

```
Tests/
├── Domain/
│   └── UseCases/
│       └── Get{Name}UseCaseTests.swift
├── Data/
│   ├── {Name}RepositoryTests.swift
│   └── {Name}RemoteDataSourceTests.swift
├── Presentation/
│   └── {ScreenName}/
│       ├── ViewModels/
│       │   └── {ScreenName}ViewModelTests.swift
│       └── Snapshots/
│           └── {ScreenName}ViewSnapshotTests.swift
├── Container/
│   └── {Feature}ContainerTests.swift
├── Stubs/                        # Domain model test data
│   ├── Character+Stub.swift
│   └── Location+Stub.swift
├── Fixtures/                     # JSON fixtures for DTOs
│   ├── character.json
│   └── character_list.json
├── Mocks/                        # Internal test mocks
│   ├── Get{Name}UseCaseMock.swift
│   └── {Name}RepositoryMock.swift
└── Helpers/                      # Test utilities
    └── SnapshotStubs.swift
```

---

## Mocks Location

| Location | Visibility | Usage |
|----------|------------|-------|
| `Mocks/` (framework) | Public | Mocks used by other modules |
| `Tests/Mocks/` | Internal | Mocks only used within the test target |

```
FeatureName/
├── Mocks/                    # Public mocks (ChallengeFeatureNameMocks framework)
│   └── {Name}RepositoryMock.swift
└── Tests/
    └── Mocks/                # Internal test-only mocks
        └── {Name}DataSourceMock.swift
```

---

## Core Module

```
Libraries/Core/
├── Sources/
│   ├── Navigation/
│   │   ├── Router.swift
│   │   ├── RouterContract.swift
│   │   └── Navigation.swift
│   ├── Components/
│   │   └── CachedAsyncImage.swift
│   └── Extensions/
│       └── ...
├── Tests/
└── Mocks/
    ├── RouterMock.swift
    ├── ImageLoaderMock.swift
    └── Bundle+JSON.swift
```

---

## Networking Module

```
Libraries/Networking/
├── Sources/
│   ├── HTTPClient.swift
│   ├── HTTPClientContract.swift
│   ├── Endpoint.swift
│   ├── HTTPMethod.swift
│   └── HTTPError.swift
├── Tests/
└── Mocks/
    └── HTTPClientMock.swift
```

---

## AppConfiguration Module

```
Libraries/AppConfiguration/
├── Sources/
│   └── Environment.swift
└── Tests/
```

---

## App Directory

```
App/
├── Sources/
│   ├── ChallengeApp.swift        # App entry point
│   ├── ContentView.swift         # Root view with navigation
│   └── Resources/
│       └── Assets.xcassets/
│           ├── AppIcon.appiconset/        # Production icon
│           ├── AppIconDev.appiconset/     # Development icon
│           └── AppIconStaging.appiconset/ # Staging icon
├── Tests/                        # Unit tests for App target
└── E2ETests/                     # End-to-end UI tests
    ├── Robots/
    └── Tests/
```

---

## File Naming Summary

| Component | Naming Pattern | Example |
|-----------|----------------|---------|
| Feature folder | `{Name}/` | `Character/` |
| Public entry | `{Feature}Feature.swift` | `CharacterFeature.swift` |
| Navigation | `{Feature}Navigation.swift` | `CharacterNavigation.swift` |
| Container | `{Feature}Container.swift` | `CharacterContainer.swift` |
| Domain model | `{Name}.swift` | `Character.swift` |
| DTO | `{Name}DTO.swift` | `CharacterDTO.swift` |
| UseCase | `{Action}{Name}UseCase.swift` | `GetCharacterUseCase.swift` |
| Repository | `{Name}Repository.swift` | `CharacterRepository.swift` |
| Contract | `{Name}Contract.swift` | `CharacterRepositoryContract.swift` |
| DataSource | `{Name}{Type}DataSource.swift` | `CharacterRemoteDataSource.swift` |
| View | `{ScreenName}View.swift` | `CharacterDetailView.swift` |
| ViewModel | `{ScreenName}ViewModel.swift` | `CharacterDetailViewModel.swift` |
| ViewState | `{ScreenName}ViewState.swift` | `CharacterDetailViewState.swift` |
| Test | `{Component}Tests.swift` | `CharacterRepositoryTests.swift` |
| Stub | `{Name}+Stub.swift` | `Character+Stub.swift` |
| Mock | `{Name}Mock.swift` | `CharacterRepositoryMock.swift` |
| Extension | `{Type}+{Purpose}.swift` | `URL+QueryItems.swift` |
| JSON fixture | `{name}.json` | `character.json` |

---

## Checklist

- [ ] Feature folder does not contain "Feature" suffix
- [ ] Sources organized by layer: Domain, Data, Presentation
- [ ] Presentation organized by screen: {ScreenName}/Views/, {ScreenName}/ViewModels/
- [ ] Tests mirror Sources structure
- [ ] Extensions in dedicated `Extensions/` folder
- [ ] Extension files named `{Type}+{Purpose}.swift`
- [ ] Mocks in correct location (Tests/Mocks/ vs Mocks/)
- [ ] Stubs in Tests/Stubs/
- [ ] JSON fixtures in Tests/Fixtures/
