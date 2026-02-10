---
name: view
description: Creates SwiftUI Views with ViewModel integration. Use when creating views, integrating with ViewModels, adding SwiftUI previews, implementing state rendering, or setting up accessibility identifiers and localized strings.
---

# Skill: View

Guide for creating SwiftUI Views that use ViewModels with dependency injection.

## Scope & Boundaries

This skill owns **only** `Sources/Presentation/{Screen}/Views/` and its snapshot tests.

| Need | Delegate to |
|------|-------------|
| ViewModel creation | `/viewmodel` skill |
| Design tokens & components | `/design-system` skill |
| Snapshot tests setup | `/snapshot` skill |
| UI tests & robots | `/ui-tests` skill |
| Navigation wiring | `/navigator` skill |

---

## Workflow

### Step 1 — Identify View Type

| Type | When | Reference |
|------|------|-----------|
| Stateful | ViewModel has `@Observable` + `state` property | [references/stateful.md](references/stateful.md) |
| Stateless | ViewModel has actions only, no observable state | [references/stateless.md](references/stateless.md) |

### Step 2 — Ensure ViewModel Exists

Before creating the View, verify the required ViewModel exists in `Sources/Presentation/{Screen}/ViewModels/`.

- **ViewModel found?** → Go to Step 3
- **No ViewModel found?** → Invoke the `/viewmodel` skill first. Return here after completion.

### Step 3 — Implement View

Read the appropriate reference from Step 1 and implement. Each reference includes: View struct, subviews, LocalizedStrings, AccessibilityIdentifier, previews, snapshot test stub, and snapshot test examples.

1. View in `Sources/Presentation/{Screen}/Views/`
2. Snapshot test stub in `Tests/Shared/Stubs/`
3. Snapshot tests in `Tests/Snapshots/Presentation/{Screen}/`
4. Run tests

---

## Core Conventions

### Struct Rules

- **Generic over contract** — `<ViewModel: {Screen}ViewModelContract>` for testability
- **Stateful**: `@State private var viewModel` with `_viewModel = State(initialValue:)` in init
- **Stateless**: `let viewModel` (no `@State` needed)
- **Internal visibility** — no `public` or `private` on View struct
- **No Router in View** — delegate all actions to ViewModel

### Design System Integration

> **CRITICAL:** All views must use the `/design-system` skill for UI construction.

- Use design tokens (colors, typography, spacing) from `{AppName}DesignSystem`
- Use atomic components (`DSCardInfoRow`, `DSAsyncImage`, etc.)
- No hardcoded values — never use raw colors, font sizes, or spacing values
- Create new DS components if needed before using in feature views

### DS Accessibility Propagation

Pass `accessibilityIdentifier:` parameter or `.dsAccessibilityIdentifier()` to DS components. Identifiers propagate to children: `.image`, `.title`, `.status` suffixes.

### LocalizedStrings

- Private enum per View file
- Import `{AppName}Resources`, use `.localized()`
- Group related strings in nested enums (`Empty`, `Error`)
- Use functions for strings with interpolation

### AccessibilityIdentifier

- Private enum per View file
- Format: `{screenName}.{elementType}`
- Static functions for dynamic IDs (e.g., `row(id:)`)
- `.accessibilityIdentifier()` for SwiftUI elements, `.dsAccessibilityIdentifier()` / `accessibilityIdentifier:` for DS components

### Previews

- Commented out (`/* */`) to exclude from coverage
- One preview per visual state except `idle`
- Stubs wrapped in `#if DEBUG`
- Stateful: `@Observable` stub with state injection + `PreviewError` enum
- Stateless: plain `final class` stub with no-op methods, single preview

### App-Level Exception

`RootContainerView` and similar app-level containers are exceptions: not generic, no `LocalizedStrings`, no `AccessibilityIdentifier`, no `.onFirstAppear`. Located at `AppKit/Sources/Presentation/Views/`.

---

## File Structure

```
Features/{Feature}/
├── Sources/Presentation/{Screen}/
│   ├── Views/
│   │   └── {Screen}View.swift
│   └── ViewModels/
└── Tests/
    ├── Snapshots/Presentation/{Screen}/
    │   ├── {Screen}ViewSnapshotTests.swift
    │   └── __Snapshots__/
    └── Shared/Stubs/
        └── {Screen}ViewModelStub.swift
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| View | internal | `Sources/Presentation/{Screen}/Views/` |
| LocalizedStrings | private | inside View file |
| AccessibilityIdentifier | private | inside View file |
| Preview stubs | private | inside View file (`#if DEBUG`) |
| Snapshot stub | internal | `Tests/Shared/Stubs/` |

---

## Checklist

### All Views
- [ ] Consult `/design-system` skill before building the view
- [ ] Generic over ViewModel contract
- [ ] Import `{AppName}Resources` and `{AppName}DesignSystem`
- [ ] Use design tokens — no hardcoded values
- [ ] Add private `LocalizedStrings` enum
- [ ] Add private `AccessibilityIdentifier` enum
- [ ] Apply accessibility identifiers (SwiftUI + DS propagation)
- [ ] Delegate user actions to ViewModel methods
- [ ] Add previews for each visual state (except `idle`)
- [ ] Create snapshot test stub and tests

### Stateful Views
- [ ] `@State private var viewModel` with `State(initialValue:)` init
- [ ] `.onFirstAppear { await viewModel.didAppear() }`
- [ ] `@ViewBuilder content` with `switch viewModel.state`
- [ ] Handle all ViewState cases

### Stateless Views
- [ ] `let viewModel` (no `@State`)
- [ ] `.onFirstAppear { viewModel.didAppear() }` (sync, no `await`)
- [ ] No `switch` on state — layout is fixed
