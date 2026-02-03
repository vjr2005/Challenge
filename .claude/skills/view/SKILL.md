---
name: view
description: Creates SwiftUI Views with ViewModel integration. Use when creating views, integrating with ViewModels, or adding SwiftUI previews.
---

# Skill: View

Guide for creating SwiftUI Views that use ViewModels with dependency injection.

## When to use this skill

- Create a new View for a feature
- Integrate View with ViewModel via init
- Add SwiftUI Previews with ViewModel stubs

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## File structure

```
Features/{Feature}/
├── Sources/
│   └── Presentation/
│       ├── {Name}List/
│       │   ├── Views/
│       │   │   └── {Name}ListView.swift
│       │   └── ViewModels/
│       └── {Name}Detail/
│           ├── Views/
│           │   └── {Name}DetailView.swift
│           └── ViewModels/
└── Tests/
    └── Presentation/
        └── Snapshots/
```

---

## View Pattern

Views are generic over ViewModel contract and receive ViewModel via init:

### Stateful Views (with ViewState)

```swift
struct {Name}View<ViewModel: {Name}ViewModelContract>: View {
    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task { await viewModel.didAppear() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle: Color.clear
        case .loading: ProgressView()
        case .loaded(let data): Text(data.name)
        case .error: ContentUnavailableView("Error", systemImage: "exclamationmark.triangle")
        }
    }
}
```

### Stateless Views (no ViewState)

Use this pattern when the ViewModel has **no observable state** - only action methods (navigation, triggers). The ViewModel does not use `@Observable` and the View does not need to observe changes.

```swift
struct {Name}View<ViewModel: {Name}ViewModelContract>: View {
    let viewModel: ViewModel

    var body: some View {
        Button("Action") {
            viewModel.didTapOnButton()
        }
    }
}
```

**When to use stateless pattern:**
- ViewModel only has action methods (e.g., `didTapOnButton()`, `navigateTo...()`)
- ViewModel does NOT have a `state` property
- ViewModel does NOT use `@Observable` macro
- No async data loading required

**Rules:**
- **Generic over contract** - Use `<ViewModel: {Name}ViewModelContract>` for testability
- **Stateful views** - Use `@State` + `_viewModel = State(initialValue:)` pattern when ViewModel has observable state
- **Stateless views** - Use `let viewModel` (no `@State` needed) when ViewModel only exposes actions
- **Switch on state** - Use `switch` on `viewModel.state` for stateful views only
- **@ViewBuilder** - Use for computed properties returning Views
- **Internal visibility**
- **No Router in View** - Delegate actions to ViewModel

---

## Exceptions: App-Level Container Views

`RootContainerView` and similar app-level navigation containers are **exceptions** to the standard View pattern:

- **Not generic over ViewModel** - receives `AppContainer` directly
- **No LocalizedStrings** - doesn't display user-facing text
- **No AccessibilityIdentifier** - navigation container, not interactive UI
- **No `.task` modifier** - manages navigation, not data loading
- **Location:** `AppKit/Sources/Presentation/Views/`

These containers orchestrate navigation and feature composition, not user interface rendering.

---

## Design System Integration

> **CRITICAL:** All views must use the `/design-system` skill for UI construction. Use existing design tokens (colors, typography, spacing) and atomic components from the DesignSystem target.

**Rules:**
- **Always consult `/design-system`** before building any view
- **Use design tokens** - colors, typography, spacing from DesignSystem
- **Use atomic components** - buttons, cards, labels from DesignSystem
- **No hardcoded values** - never use raw colors, font sizes, or spacing values
- **Create new components if needed** - if a view requires something more complex that doesn't exist, create a new reusable component in the DesignSystem target first, then use it in the feature view

```swift
// ✅ Correct - using design system
import {AppName}DesignSystem

Text(item.name)
    .font(Typography.bodyLarge)
    .foregroundStyle(SemanticColor.textPrimary)
    .padding(Spacing.medium)

// ❌ Wrong - hardcoded values
Text(item.name)
    .font(.system(size: 16))
    .foregroundStyle(.black)
    .padding(16)
```

---

## State Rendering

Always use a `switch` statement to render based on ViewState:

```swift
@ViewBuilder
private var content: some View {
    switch viewModel.state {
    case .idle: Color.clear
    case .loading: ProgressView()
    case .empty: ContentUnavailableView("No items", systemImage: "tray")
    case .loaded(let data): DataView(data: data)
    case .error: ContentUnavailableView("Error", systemImage: "exclamationmark.triangle")
    }
}
```

---

## Navigation

List Views delegate navigation to ViewModel:

```swift
List(items) { item in
    Button(item.name) {
        viewModel.didSelect(item)  // Delegate to ViewModel
    }
}
```

**Rules:**
- View only knows ViewModel
- User actions call ViewModel methods
- ViewModel handles navigation via Router

---

## Previews

All Views should include previews. Create one for **each state except `idle`**.

> **Note:** Previews are commented out by default (`/* */`) in this project to avoid negatively impacting test coverage metrics. The preview code should still be maintained and kept up-to-date with the View implementation, but disabled to exclude from coverage reports.

### Preview Rules

- **Skip `idle` state** - transient state with no visual content
- **One preview per visual state** - Loading, Loaded, Empty, Error
- **Use descriptive names** - `#Preview("Loading")`
- **Use ViewModel stubs** - same pattern as snapshot tests for consistency
- **Comment out by default** - wrap in `/* */` to exclude from coverage (keep code maintained)

### Preview Stub Pattern

Use ViewModel stubs with direct state injection (same pattern as snapshot tests).

> **IMPORTANT:** Wrap preview stubs in `#if DEBUG` to exclude them from release builds. The `#Preview` macro is already excluded automatically by the compiler.

```swift
/*
// MARK: - Previews

#Preview("Loading") {
    NavigationStack {
        {Name}View(viewModel: {Name}ViewModelPreviewStub(state: .loading))
    }
}

#Preview("Loaded") {
    NavigationStack {
        {Name}View(viewModel: {Name}ViewModelPreviewStub(state: .loaded(.previewStub())))
    }
}

#Preview("Error") {
    NavigationStack {
        {Name}View(viewModel: {Name}ViewModelPreviewStub(state: .error(PreviewError.failed)))
    }
}
*/

// MARK: - Preview Stubs

#if DEBUG
@Observable
private final class {Name}ViewModelPreviewStub: {Name}ViewModelContract {
    var state: {Name}ViewState

    init(state: {Name}ViewState) {
        self.state = state
    }

    func didAppear() async {}
    func didTapOnRetryButton() async {}
    // Add other protocol methods as no-ops
}

private extension {Model} {
    static func previewStub(
        id: Int = 1,
        name: String = "Sample Name"
        // Add other properties with defaults
    ) -> {Model} {
        {Model}(id: id, name: name, ...)
    }
}

private enum PreviewError: LocalizedError {
    case failed
    var errorDescription: String? { "Failed to load" }
}
#endif
```

> **Note:** For stateless views (no ViewState), use ViewModel stubs with no-op implementations:
> ```swift
> #if DEBUG
> private final class {Name}ViewModelPreviewStub: {Name}ViewModelContract {
>     func didTapOnButton() {}
> }
> #endif
> ```

---

## Localized Strings

Views must define **private LocalizedStrings** for type-safe localization.

```swift
import {AppName}Resources

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "screenName.title".localized() }
    static var subtitle: String { "screenName.subtitle".localized() }
    static func itemCount(_ count: Int) -> String {
        "screenName.itemCount %lld".localized(count)
    }

    enum Empty {
        static var title: String { "screenName.empty.title".localized() }
        static var description: String { "screenName.empty.description".localized() }
    }
}
```

**Rules:**
- Private to each View
- Use `localized()` from `{AppName}Common`
- Group related strings in nested enums
- Use functions for strings with interpolation

---

## Accessibility Identifiers

Views must define **private accessibility identifiers** for UI testing.

```swift
// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "{name}.scrollView"
    static let actionButton = "{name}.actionButton"
    static let emptyState = "{name}.emptyState"

    static func row(id: Int) -> String {
        "{name}.row.\(id)"
    }
}
```

### Usage

Use `.accessibilityIdentifier()` for standard SwiftUI elements and the `accessibilityIdentifier:` parameter for DS components:

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            DSCardInfoRow(
                imageURL: item.imageURL,
                title: item.name,
                accessibilityIdentifier: AccessibilityIdentifier.row(id: item.id)
            )
        }
    }
}
.accessibilityIdentifier(AccessibilityIdentifier.scrollView)
```

### DS Propagation

When passing `accessibilityIdentifier:` to DS components, identifiers propagate to child components with suffixes:
- `DSAsyncImage`: `.image`
- Title text: `.title`
- `DSStatusIndicator`: `.status`

**Rules:**
- Private to each View
- Format: `{screenName}.{elementType}`
- Use static functions for dynamic IDs
- Pass `accessibilityIdentifier:` parameter to DS components for propagation

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| View | internal | `Sources/Presentation/{Feature}/Views/` |

---

## Checklist

### All Views
- [ ] Consult `/design-system` skill before building the view
- [ ] Create View struct with init receiving ViewModel only
- [ ] Import `{AppName}Common` for localization
- [ ] Import `{AppName}DesignSystem` for UI components
- [ ] Use design tokens (colors, typography, spacing) - no hardcoded values
- [ ] Create new DesignSystem components if needed for complex UI
- [ ] Add private `LocalizedStrings` enum with all strings
- [ ] Delegate user actions to ViewModel methods
- [ ] Add private `AccessibilityIdentifier` enum
- [ ] Apply `.accessibilityIdentifier()` to standard SwiftUI elements
- [ ] Pass `accessibilityIdentifier:` parameter to DS components for propagation
- [ ] Add Previews for each state (except idle)

### Stateful Views (with ViewState)
- [ ] Use `@State private var viewModel` with `_viewModel = State(initialValue:)` in init
- [ ] Implement `body` with `.task { await viewModel.didAppear() }`
- [ ] Implement `content` with switch on `viewModel.state`
- [ ] Handle all ViewState cases

### Stateless Views (navigation only, no async data)
- [ ] Use `let viewModel` (no `@State` needed)
- [ ] No `.task` modifier needed (no async data loading)
- [ ] No `didAppear()` method in ViewModel
