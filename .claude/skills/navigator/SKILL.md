---
name: navigator
description: Creates Navigator for navigation. Use when setting up navigation, adding navigation to ViewModels, or testing navigation behavior.
---

# Skill: Navigator

Guide for implementing navigation using NavigationCoordinator with SwiftUI NavigationStack, Navigator pattern for decoupling, and Outgoing/Incoming Navigation for cross-feature communication.

## References

- **Core components** (protocols, NavigationCoordinator, NavigatorMock): See [references/core-components.md](references/core-components.md)
- **Feature implementation** (Incoming/Outgoing, DeepLinkHandler, Navigator, modal, App layer): See [references/feature-implementation.md](references/feature-implementation.md)
- **Tests** (Navigator, DeepLinkHandler, AppNavigationRedirect tests): See [references/tests.md](references/tests.md)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          RootContainerView                              │
│  @State private var coordinator = NavigationCoordinator(                │
│      redirector: AppNavigationRedirect()                                │
│  )                                                                      │
│                                                                         │
│  NavigationStack(path: $coordinator.path) { ... }                       │
│  .sheet(item: $coordinator.sheetNavigation) { modal in                  │
│      ModalContainerView(modal:appContainer:onDismiss:)                  │
│  }                                                                      │
│  .fullScreenCover(item: $coordinator.fullScreenCoverNavigation) { ... } │
└─────────────────────────────────────────────────────────────────────────┘

Push Navigation Flow:
1. HomeNavigator.navigateToCharacters()
2. coordinator.navigate(to: HomeOutgoingNavigation.characters)
3. AppNavigationRedirect.redirect() → CharacterIncomingNavigation.list
4. NavigationStack shows CharacterListView

Modal Navigation Flow:
1. Navigator.presentFilter()
2. coordinator.present(Navigation.filter, style: .sheet(detents: [.medium, .large]))
3. sheetNavigation is set → .sheet(item:) activates
4. ModalContainerView creates its own NavigationCoordinator + NavigationStack
5. Modal can push internally or present nested modals
```

---

## Navigation Types

| Type | Description | Implementation |
|------|-------------|----------------|
| **Incoming** | Destinations a feature can handle | `{Feature}IncomingNavigation` enum |
| **Outgoing** | Destinations a feature wants to navigate to | `{Feature}OutgoingNavigation` enum |
| **Redirect** | Connects Outgoing → Incoming | `AppNavigationRedirect` in App layer |

**Why?** Features remain decoupled. Feature A doesn't import Feature B. The App layer connects them via redirects.

---

## Navigator Pattern

ViewModels use **Navigators** instead of NavigatorContract directly. This:
1. Decouples ViewModels from navigation implementation details
2. Makes testing easier with focused mocks
3. Provides semantic navigation methods

**Key Difference:**
- **Internal navigation:** Uses `{Feature}IncomingNavigation` directly
- **External navigation:** Uses `{Feature}OutgoingNavigation` (redirected by App layer)

---

## Modal Navigation

| Style | Description |
|-------|-------------|
| `.sheet(detents:)` | Presents as a sheet with configurable detents (default: `[.large]`) |
| `.fullScreenCover` | Presents as a full-screen cover |

- `present(_:style:)` — sets `sheetNavigation` or `fullScreenCoverNavigation` on the coordinator
- `dismiss()` — priority: fullScreenCover > sheet > parent onDismiss

---

## File Structure

```
Libraries/Core/
├── Sources/Navigation/
│   ├── NavigationCoordinator.swift
│   ├── NavigatorContract.swift
│   ├── NavigationRedirectContract.swift
│   ├── Navigation.swift
│   ├── AnyNavigation.swift
│   ├── ModalPresentationStyle.swift
│   ├── ModalNavigation.swift
│   └── DeepLinkHandler.swift
└── Mocks/
    └── NavigatorMock.swift

AppKit/Sources/
├── AppContainer.swift
└── Presentation/
    ├── Navigation/AppNavigationRedirect.swift
    └── Views/
        ├── NavigationContainerView.swift
        ├── RootContainerView.swift
        └── ModalContainerView.swift

Features/{Feature}/
├── Sources/Presentation/
│   ├── Navigation/
│   │   ├── {Feature}IncomingNavigation.swift
│   │   ├── {Feature}OutgoingNavigation.swift
│   │   └── {Feature}DeepLinkHandler.swift
│   └── {Screen}/
│       ├── Navigator/
│       │   ├── {Screen}NavigatorContract.swift
│       │   └── {Screen}Navigator.swift
│       └── Tracker/
│           ├── {Screen}TrackerContract.swift
│           ├── {Screen}Tracker.swift
│           └── {Screen}Event.swift
└── Tests/Unit/Presentation/
    ├── Navigation/{Feature}DeepLinkHandlerTests.swift
    └── {Screen}/Navigator/{Screen}NavigatorTests.swift
```

---

## Checklist

### Core Setup
- [ ] Core has `NavigatorContract` protocol (navigate, present, dismiss, goBack)
- [ ] Core has `NavigationCoordinator` (@Observable, manages path + modals + redirects)
- [ ] Core has `NavigationContract`, `IncomingNavigationContract`, `OutgoingNavigationContract`
- [ ] Core has `AnyNavigation` type-erased wrapper
- [ ] Core has `ModalPresentationStyle` and `ModalNavigation`
- [ ] Core has `DeepLinkHandlerContract` and `FeatureContract`
- [ ] Core has `NavigatorMock` for testing

### AppKit Configuration
- [ ] `AppNavigationRedirect` in `AppKit/Sources/Presentation/Navigation/`
- [ ] `NavigationContainerView` (NavigationStack + push + modals)
- [ ] `RootContainerView` uses `NavigationContainerView` + `.onOpenURL`
- [ ] `ModalContainerView` (creates own coordinator, uses `NavigationContainerView`)
- [ ] `AppContainer.resolve()` iterates features and falls back to NotFoundView
- [ ] `AppContainer.handle(url:navigator:)` resolves deep links via feature handlers

### Feature Implementation
- [ ] `{Feature}IncomingNavigation` in `Presentation/Navigation/`
- [ ] `{Feature}OutgoingNavigation` for cross-feature navigation (if needed)
- [ ] `{Feature}DeepLinkHandler` returning `IncomingNavigationContract` (if deep links needed)
- [ ] Each screen has `NavigatorContract` and `Navigator`
- [ ] Navigator uses `IncomingNavigationContract` for internal, `OutgoingNavigationContract` for external
- [ ] Container factories receive `navigator: any NavigatorContract`

### Testing
- [ ] Navigator tests verify correct Navigation enum is used
- [ ] AppNavigationRedirect tests verify Outgoing → Incoming mapping
- [ ] DeepLinkHandler tests verify URL → IncomingNavigationContract resolution
