---
name: dependency-injection
description: Creates Containers for dependency injection. Use when creating feature containers, exposing public entry points, or wiring up dependencies.
---

# Skill: Dependency Injection

Guide for creating dependency injection with Container per Feature pattern.

## When to use this skill

- Create a Container for a feature
- Expose a public entry point for the feature
- Wire up dependencies with lazy properties for stateful objects

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## File structure

```
Libraries/Features/{FeatureName}/
├── Sources/
│   ├── {Feature}Feature.swift              # Public entry point (enum with view builder)
│   ├── {Feature}Navigation.swift           # Public navigation destinations
│   ├── Container/
│   │   └── {Feature}Container.swift        # Internal container (lazy repository)
│   ├── Domain/
│   ├── Data/
│   └── Presentation/
│       ├── {Name}List/
│       │   ├── Views/
│       │   └── ViewModels/
│       └── {Name}Detail/
│           ├── Views/
│           └── ViewModels/
```

**Notes:**
- Container is at the root of Sources/, NOT inside Presentation/
- Container is accessed via static property in `{Feature}Feature` enum
- Views receive **only ViewModel** via init
- Navigation is handled by App using `NavigationPath`

---

## Navigation Destinations

```swift
// Sources/{Feature}Navigation.swift
import {AppName}Core

public enum {Feature}Navigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

**Rules:**
- Conform to `Navigation` protocol (from Core module)
- Use primitive types for parameters (Int, String, Bool, UUID)
- Never pass domain objects - only identifiers

---

## Public Entry Point

```swift
// Sources/{Feature}Feature.swift
import {AppName}Core
import SwiftUI

public enum {Feature}Feature {
    private static let container = {Feature}Container()

    @ViewBuilder
    public static func view(for navigation: {Feature}Navigation, router: RouterContract) -> some View {
        switch navigation {
        case .list:
            {Name}ListView(viewModel: container.makeListViewModel(router: router))
        case .detail(let identifier):
            {Name}DetailView(viewModel: container.makeDetailViewModel(identifier: identifier, router: router))
        }
    }
}
```

**Rules:**
- **public enum** - Prevents instantiation, only static access
- **private static let container** - Shared container (lazy repository is source of truth)
- **view(for:router:)** - Builds view for each navigation destination
- **router parameter** - Passed to Container factories for ViewModel injection

---

## Internal Container

```swift
// Sources/Container/{Feature}Container.swift
import {AppName}Networking
import Foundation

final class {Feature}Container {
    // MARK: - Infrastructure

    private let httpClient: any HTTPClientContract

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(baseURL: APIConfiguration.baseURL)
    }

    // MARK: - Shared (lazy) - Source of Truth

    private let memoryDataSource = {Name}MemoryDataSource()

    private lazy var repository: any {Name}RepositoryContract = {Name}Repository(
        remoteDataSource: {Name}RemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    // MARK: - Factories

    func makeListViewModel(router: RouterContract) -> {Name}ListViewModel {
        {Name}ListViewModel(
            get{Name}sUseCase: makeGet{Name}sUseCase(),
            router: router
        )
    }

    func makeDetailViewModel(identifier: Int, router: RouterContract) -> {Name}DetailViewModel {
        {Name}DetailViewModel(
            identifier: identifier,
            get{Name}UseCase: makeGet{Name}UseCase(),
            router: router
        )
    }

    private func makeGet{Name}sUseCase() -> some Get{Name}sUseCaseContract {
        Get{Name}sUseCase(repository: repository)
    }

    private func makeGet{Name}UseCase() -> some Get{Name}UseCaseContract {
        Get{Name}UseCase(repository: repository)
    }
}
```

**Rules:**
- **final class** - Allows instance properties and lazy initialization
- **httpClient via init** - Optional injection for testability
- **lazy var repository** - Source of truth, initialized on first access
- **Private UseCase factories** - Only ViewModels are created externally
- **Internal visibility** - Container is not public

---

## Lazy vs Factory

| Type | Pattern | Reason |
|------|---------|--------|
| HTTPClient | Optional init parameter | Injectable for tests |
| MemoryDataSource | Instance property | Maintains cache state |
| Repository | `lazy var` | Source of truth |
| ViewModel | Factory method | New instance per navigation |
| UseCase | Factory method | Stateless, can be new |

---

## Visibility Summary

| Component | Visibility | Reason |
|-----------|------------|--------|
| Contract (Protocol) | **public** | API for consumers, enables DI |
| Implementation (Class) | **public** / **open** | Direct instantiation allowed |
| {Feature}Navigation | **public** | Navigation destinations |
| {Feature}Feature | **public** | Entry point with `view(for:)` |
| {Feature}Container | internal | Internal wiring |
| Views | internal | Internal UI |

---

## Testing Containers

Containers must be tested to verify correct dependency wiring.

### File Structure

```
Libraries/Features/{FeatureName}/
└── Tests/
    └── Container/
        └── {Feature}ContainerTests.swift
```

### What to Test

| Test | Purpose |
|------|---------|
| Factory returns instance | Verify wiring doesn't crash |
| Shared repository | Verify lazy var is reused across ViewModels |
| Injected dependencies | Verify mock is used when injected |

For complete test examples, see [examples.md](examples.md).

---

## Checklist

- [ ] Create `{Feature}Navigation.swift` conforming to `Navigation` protocol
- [ ] Create `{Feature}Feature.swift` with static container and `view(for:)` method
- [ ] Create internal Container as `final class` with optional `httpClient` in init
- [ ] Use `lazy var` for repository (source of truth)
- [ ] Views only receive ViewModel
- [ ] Use factory methods for ViewModels
- [ ] App registers `.navigationDestination(for: {Feature}Navigation.self)`
- [ ] **Create container tests verifying factory methods and shared repository**
