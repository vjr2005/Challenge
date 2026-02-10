---
name: dependency-injection
description: Creates Features for dependency injection. Use when creating features, exposing public entry points, or wiring up dependencies.
---

# Skill: Dependency Injection

Guide for creating dependency injection with Composition Root pattern.

## References

- **AppContainer** (Composition Root, RootContainerView): See [references/app-container.md](references/app-container.md)
- **Feature & Container** (Feature struct, Container, navigation, simple feature): See [references/feature-container.md](references/feature-container.md)
- **Tests** (feature tests, generic pattern): See [references/tests.md](references/tests.md)

---

## Architecture Overview

```
ChallengeApp
    │
    └── AppContainer (Composition Root)
        │
        ├── httpClient: HTTPClientContract
        ├── tracker: TrackerContract
        ├── imageLoader: ImageLoaderContract → SwiftUI Environment
        │
        └── features: [Feature]
            ├── CharacterFeature (navigation + deep links)
            │   └── CharacterContainer (DI composition)
            │       ├── repository
            │       ├── makeCharacterListViewModel()
            │       └── makeCharacterDetailViewModel()
            │
            └── HomeFeature (navigation)
                └── HomeContainer (DI composition)
                    └── makeHomeViewModel()
```

---

## Key Concepts

- **AppContainer**: Composition Root — creates shared dependencies (HTTPClient, Tracker) and all features
- **{Feature}Container**: Handles dependency composition (repositories, factories)
- **{Feature}Feature**: Handles navigation and deep links, delegates DI to Container
- Views receive **only ViewModel** via init
- Navigation is handled by App using `NavigationCoordinator`

---

## File Structure

```
App/
├── Sources/
│   └── {AppName}App.swift

AppKit/
├── Sources/
│   ├── AppContainer.swift
│   ├── Presentation/
│   │   ├── Navigation/
│   │   │   └── AppNavigationRedirect.swift
│   │   └── Views/
│   │       ├── NavigationContainerView.swift
│   │       ├── RootContainerView.swift
│   │       └── ModalContainerView.swift

Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift
│   ├── {Feature}Container.swift
│   ├── Navigation/
│   │   ├── {Feature}IncomingNavigation.swift
│   │   ├── {Feature}OutgoingNavigation.swift
│   │   └── {Feature}DeepLinkHandler.swift
│   └── Presentation/
│       └── {Screen}/
│           ├── Navigator/
│           ├── Tracker/
│           ├── Views/
│           └── ViewModels/
└── Tests/
    └── Feature/
        └── {Feature}FeatureTests.swift
```

---

## Dependency Patterns

| Type | Pattern | Reason |
|------|---------|--------|
| HTTPClient | Required init parameter | Injected by AppContainer |
| Tracker | Required init parameter | Injected by AppContainer |
| ImageLoader | SwiftUI Environment | Injected by RootContainerView from AppContainer |
| Container | Created in Feature init | Owns dependency composition |
| DataSource | Local variable in Container `init` | Only needed to build repositories |
| Repository | Stored property in Container (`let`) | Built in `init`, used by factory methods |
| Navigator | Factory method (inline) | New instance per ViewModel |
| Screen Tracker | Factory method (inline) | New instance per ViewModel |
| ViewModel | Factory method | New instance per navigation |
| UseCase | Created inline | Stateless |

---

## Visibility Summary

| Component | Visibility | Reason |
|-----------|------------|--------|
| Contract (Protocol) | **public** | API for consumers, enables DI |
| {Feature}Feature | **public** | Entry point struct |
| {Feature}Container | **public** | Created by Feature |
| Feature.makeMainView() | **public** | Creates the feature's default entry point |
| Feature.resolve() | **public** | Returns view for navigation or nil |
| Container factory methods | **internal** | Called by Feature |
| {Feature}IncomingNavigation | **public** | Used by AppNavigationRedirect |
| {Feature}OutgoingNavigation | **public** | Used by AppNavigationRedirect |
| {Feature}DeepLinkHandler | internal | Accessed via Feature.deepLinkHandler |
| Navigator / Tracker / Views | internal | Internal to feature |

---

## Checklist

- [ ] Create `AppContainer.swift` in `AppKit/Sources/` as Composition Root
- [ ] Create `AppNavigationRedirect.swift` in `AppKit/Sources/Presentation/Navigation/`
- [ ] Create `RootContainerView.swift` in `AppKit/Sources/Presentation/Views/`
- [ ] Create `{Feature}Container.swift` for dependency composition
- [ ] Create `{Feature}Feature.swift` as struct implementing `FeatureContract` protocol
- [ ] Feature requires `httpClient` and `tracker` in init
- [ ] Feature creates Container in init, passing `tracker`
- [ ] Container builds DataSources as local variables in `init`
- [ ] Container has stored `repository` properties (`private let`)
- [ ] Container has factory methods receiving `navigator: any NavigatorContract`
- [ ] Create `{Feature}IncomingNavigation.swift`
- [ ] Create `{Feature}OutgoingNavigation.swift` for cross-feature navigation (if needed)
- [ ] Create `{Feature}DeepLinkHandler.swift` (only if feature handles deep links)
- [ ] Add feature to `AppContainer.features` array
- [ ] `ChallengeApp` imports `ChallengeAppKit` and uses `RootContainerView`
- [ ] **Create feature tests**
