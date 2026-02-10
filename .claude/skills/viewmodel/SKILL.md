---
name: viewmodel
description: Creates ViewModels with state management. Use when creating ViewModels, implementing ViewState pattern, or adding state management for features. Delegates to /usecase for domain use cases and to /feature for Container/Feature wiring.
---

# Skill: ViewModel

Guide for creating ViewModels that manage state and coordinate between Views and UseCases.

## Scope & Boundaries

This skill owns **only** `Sources/Presentation/{Screen}/ViewModels/` and its tests.

| Need | Delegate to |
|------|-------------|
| Domain UseCases | `/usecase` skill |
| Container / Feature wiring | `/feature` skill |
| Navigator / Tracker | `/navigator` skill |

---

## Workflow

### Step 1 — Identify ViewModel Type

| Type | When | Reference |
|------|------|-----------|
| Stateless | Navigation + tracking only, no observable state | [references/stateless.md](references/stateless.md) |
| Stateful Detail | Single item load + optional refresh | [references/stateful-detail.md](references/stateful-detail.md) |
| Stateful List | List load + empty/error + optional refresh | [references/stateful-list.md](references/stateful-list.md) |
| Debounced Search | Search with debounce + recent searches (extends list) | [references/debounced-search.md](references/debounced-search.md) |
| Stateful Filter | Mutable filter with computed properties | [references/stateful-filter.md](references/stateful-filter.md) |

### Step 2 — Ensure UseCases Exist

Before creating the ViewModel, verify required UseCases exist in `Sources/Domain/UseCases/`.

- **UseCases found?** → Go to Step 3
- **No UseCases found?** → Invoke the `/usecase` skill first. Return here after completion.

### Step 3 — Implement ViewModel

Read the appropriate reference from Step 1 and implement. Each reference includes: Contract, ViewState (if applicable), ViewModel, View integration snippet, Container factory snippet, Test structure, Mock, and Stub.

1. Contract + ViewState + ViewModel in `Sources/Presentation/{Screen}/ViewModels/`
2. Mock in `Tests/Shared/Mocks/`
3. Tests in `Tests/Unit/Presentation/{Screen}/ViewModels/`
4. Run tests

---

## Core Conventions

### Class Rules

- `@Observable` **only** when `private(set) var` state exists; stateless ViewModels are plain `final class`
- `final class`, internal visibility, no explicit `@MainActor` (project default isolation)
- Protocol = `{Screen}ViewModelContract: AnyObject`

### Method Naming

All protocol methods describe the **UI event**, using the `did` prefix:

| UI Event | Protocol Method |
|----------|-----------------|
| View appears (`.onFirstAppear {}`) | `didAppear()` |
| Tap retry button | `didTapOnRetryButton()` |
| Pull to refresh (`.refreshable {}`) | `didPullToRefresh()` |
| Tap load more button | `didTapOnLoadMoreButton()` |
| Item selection | `didSelect(_:)` |
| Tap on button | `didTapOn{ButtonName}()` |

### Behavior Rules

- **`didAppear()`**: Called once via `.onFirstAppear` — single execution guaranteed by the View
- **`didTapOnRetryButton()`**: Always calls `load()` unconditionally
- **`didPullToRefresh()`**: Always calls the refresh use case, resets pagination
- **`didTapOnLoadMoreButton()`**: Only loads if there is a next page and not already loading more
- Public methods (`didAppear`, `didTapOnRetryButton`) call private `load()` — encapsulate loading logic

### ViewState `==` Operator

All ViewState enums implement `==` for testability (enables direct state comparison in tests). Error cases compare via `localizedDescription`. See reference files for templates.

---

## File Structure

```
Features/{Feature}/
├── Sources/Presentation/{Screen}/
│   └── ViewModels/
│       ├── {Screen}ViewModelContract.swift
│       ├── {Screen}ViewState.swift          # Only for stateful ViewModels
│       └── {Screen}ViewModel.swift
└── Tests/
    ├── Unit/Presentation/{Screen}/
    │   └── ViewModels/
    │       └── {Screen}ViewModelTests.swift
    └── Shared/Mocks/
        └── {Screen}ViewModelMock.swift
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| ViewModelContract | internal | `Sources/Presentation/{Screen}/ViewModels/` |
| ViewState | internal | `Sources/Presentation/{Screen}/ViewModels/` |
| ViewModel | internal | `Sources/Presentation/{Screen}/ViewModels/` |
| Mock | internal | `Tests/Shared/Mocks/` |

---

## Checklist

- [ ] Create ViewModelContract (`AnyObject` for stateful, plain protocol for stateless)
- [ ] Create ViewState enum with `==` operator (stateful only)
- [ ] Create ViewModel (`@Observable` for stateful, plain `final class` for stateless)
- [ ] Inject UseCases via protocol (contract)
- [ ] Inject NavigatorContract for navigation
- [ ] Inject TrackerContract for tracking
- [ ] Implement `didAppear()` / `didTapOnRetryButton()` as public, `load()` as private
- [ ] Add tracking calls in `didAppear()`, `didSelect()`, `didTapOn...()` methods
- [ ] Guard observable properties with `oldValue` check in `didSet` (search only)
- [ ] Create Mock in `Tests/Shared/Mocks/`
- [ ] Create tests for initial state, success, error, and call verification
- [ ] Run tests
