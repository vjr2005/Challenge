---
name: feature
description: Creates a new feature module with minimal viable structure. Use when bootstrapping a new feature from scratch, scaffolding the Tuist module, Container, Feature entry point, DeepLinkHandler, and initial screen with placeholder Text view. Includes all unit tests, mocks, and stubs. For adding domain/data layers afterward, use /datasource, /repository, /usecase. For enhancing views, use /view, /viewmodel, /navigator.
---

# Skill: Feature

Create a new feature module with the minimum viable structure: Tuist module, Feature entry point, Container, DeepLinkHandler, and one screen with placeholder `Text`.

## Parameters

Gather from user before starting:

| Parameter | Format | Example |
|-----------|--------|---------|
| Feature | PascalCase | `Episode` |
| Screen | PascalCase | `EpisodeList` |
| Deep link host | lowercase | `episode` |
| Deep link path | path | `/list` |

Derived values:
- **Module name**: `Challenge{Feature}` (e.g., `ChallengeEpisode`)
- **Event prefix**: snake_case of Screen (e.g., `episode_list`)

## File Structure

```
Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift
│   ├── {Feature}Container.swift
│   └── Presentation/
│       ├── Navigation/
│       │   ├── {Feature}IncomingNavigation.swift
│       │   └── {Feature}DeepLinkHandler.swift
│       └── {Screen}/
│           ├── Navigator/
│           │   ├── {Screen}NavigatorContract.swift
│           │   └── {Screen}Navigator.swift
│           ├── Tracker/
│           │   ├── {Screen}TrackerContract.swift
│           │   ├── {Screen}Tracker.swift
│           │   └── {Screen}Event.swift
│           ├── ViewModels/
│           │   ├── {Screen}ViewModelContract.swift
│           │   └── {Screen}ViewModel.swift
│           └── Views/
│               └── {Screen}View.swift
└── Tests/
    ├── Unit/
    │   ├── Feature/
    │   │   └── {Feature}FeatureTests.swift
    │   └── Presentation/
    │       ├── Navigation/
    │       │   └── {Feature}DeepLinkHandlerTests.swift
    │       └── {Screen}/
    │           ├── Navigator/
    │           │   └── {Screen}NavigatorTests.swift
    │           ├── Tracker/
    │           │   ├── {Screen}TrackerTests.swift
    │           │   └── {Screen}EventTests.swift
    │           └── ViewModels/
    │               └── {Screen}ViewModelTests.swift
    └── Shared/
        ├── Mocks/
        │   ├── {Screen}NavigatorMock.swift
        │   └── {Screen}TrackerMock.swift
        └── Stubs/
            └── {Screen}ViewModelStub.swift
```

## Workflow

### Step 1: Tuist Module

Create `Tuist/ProjectDescriptionHelpers/Modules/{Feature}Module.swift`:

```swift
import ProjectDescription

public enum {Feature}Module {
    public static let module = FrameworkModule.create(
        name: "{Feature}",
        baseFolder: "Features",
        path: "{Feature}",
        dependencies: [
            .target(name: "\(appName)Core"),
            .target(name: "\(appName)DesignSystem"),
            .target(name: "\(appName)Resources"),
        ],
        testDependencies: [
            .target(name: "\(appName)CoreMocks"),
        ],
        snapshotTestDependencies: [
            .target(name: "\(appName)CoreMocks"),
        ]
    )

    public static let targetReferences: [TargetReference] = [
        .target("\(appName){Feature}"),
    ]
}
```

Register in `Modules.swift`:
- Add `{Feature}Module.module` to `all` array (before `AppKitModule`)
- Add `{Feature}Module.targetReferences` to `codeCoverageTargets`

### Step 2: Source Files

Create all source files under `Features/{Feature}/Sources/`. See [sources.md](references/sources.md) for templates.

Creation order:
1. Navigation: `{Feature}IncomingNavigation`, `{Feature}DeepLinkHandler`
2. Navigator: `{Screen}NavigatorContract`, `{Screen}Navigator`
3. Tracker: `{Screen}TrackerContract`, `{Screen}Tracker`, `{Screen}Event`
4. ViewModel: `{Screen}ViewModelContract`, `{Screen}ViewModel`
5. View: `{Screen}View`
6. DI: `{Feature}Container`, `{Feature}Feature`

### Step 3: Test Files

Create all test files under `Features/{Feature}/Tests/`. See [tests.md](references/tests.md) for templates.

1. Mocks: `{Screen}NavigatorMock`, `{Screen}TrackerMock`
2. Stubs: `{Screen}ViewModelStub`
3. Unit tests: `{Feature}FeatureTests`, `{Feature}DeepLinkHandlerTests`, `{Screen}NavigatorTests`, `{Screen}TrackerTests`, `{Screen}EventTests`, `{Screen}ViewModelTests`

### Step 4: Verify

```bash
mise x -- tuist test --skip-ui-tests
```

## Important Conventions

- **No `@Observable`** on minimal ViewModels (no observable state). Only add `@Observable` when the ViewModel has `private(set) var` state properties.
- **No `any` keyword** on internal protocol types. Only use `any` on public protocols from other modules (e.g., `any TrackerContract` in Container init).
- **No imports** needed in ViewModel when all types are internal to the module.
- Tuist module uses `\(appName)` string interpolation for target names (e.g., `"\(appName)Core"`).

## Integration (Manual — After Feature Is Ready)

These steps wire the feature into the app. Perform when ready to use:

1. **AppContainer**: Add `{Feature}Feature` instance and register in `features` array
2. **AppKitModule**: Add `Challenge{Feature}` to dependencies (and `Challenge{Feature}Mocks` to test dependencies)
3. **AppScheme**: Add `Challenge{Feature}Tests` and `Challenge{Feature}SnapshotTests` (if exists) to Dev scheme

## Extending the Feature

Use other skills to add layers incrementally:

| Need | Skill |
|------|-------|
| REST API data source | `/datasource` |
| Repository + DTO mapping | `/repository` |
| Business logic | `/usecase` |
| Enhance ViewModel with state | `/viewmodel` |
| Enhance View with design system | `/view` |
| Add more navigation | `/navigator` |
| Snapshot tests | `/snapshot` |
| UI tests | `/ui-tests` |
