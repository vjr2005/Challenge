---
name: view
description: Creates SwiftUI Views with ViewModel integration. Use when creating views, integrating with ViewModels, or adding SwiftUI previews.
---

# Skill: View

Guide for creating SwiftUI Views that use ViewModels with dependency injection.

## When to use this skill

- Create a new View for a feature
- Integrate View with ViewModel via init
- Add SwiftUI Previews with mocks

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## File structure

```
Libraries/Features/{Feature}/
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

Views receive ViewModel via init using `_viewModel = State(initialValue:)`:

```swift
struct {Name}View: View {
    @State private var viewModel: {Name}ViewModel

    init(viewModel: {Name}ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task { await viewModel.load() }
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

**Rules:**
- **Init for ViewModel** - Use `_viewModel = State(initialValue:)` pattern
- **Switch on state** - Use `switch` on `viewModel.state`
- **@ViewBuilder** - Use for computed properties returning Views
- **Internal visibility**
- **No Router in View** - Delegate actions to ViewModel

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

All Views must include previews. Create one for **each state except `idle`**.

### Preview Rules

- **Skip `idle` state** - transient state with no visual content
- **One preview per visual state** - Loading, Loaded, Empty, Error
- **Use descriptive names** - `#Preview("Loading")`
- **Create private preview mocks** - with configurable behavior

### Preview Mock Pattern

```swift
private final class Get{Name}UseCasePreviewMock: Get{Name}UseCaseContract {
    private let delay: Bool
    private let isEmpty: Bool
    private let shouldFail: Bool

    init(delay: Bool = false, isEmpty: Bool = false, shouldFail: Bool = false) {
        self.delay = delay
        self.isEmpty = isEmpty
        self.shouldFail = shouldFail
    }

    func execute() async throws -> {Name} {
        if delay { try? await Task.sleep(for: .seconds(100)) }
        if shouldFail { throw PreviewError.failed }
        if isEmpty { return {Name}(items: []) }
        return {Name}.stubForPreview()
    }
}

private final class RouterPreviewMock: RouterContract {
    func navigate(to destination: any Navigation) {}
    func goBack() {}
}
```

---

## Localized Strings

Views must define **private LocalizedStrings** for type-safe localization.

```swift
import {AppName}Common

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

Views must define **private accessibility identifiers** for E2E testing.

```swift
// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let view = "{name}.view"
    static let actionButton = "{name}.actionButton"

    static func row(id: Int) -> String {
        "{name}.row.\(id)"
    }
}
```

**Rules:**
- Private to each View
- Format: `{screenName}.{elementType}`
- Use static functions for dynamic IDs

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| View | internal | `Sources/Presentation/{Feature}/Views/` |

---

## Checklist

- [ ] Consult `/design-system` skill before building the view
- [ ] Create View struct with init receiving ViewModel only
- [ ] Use `_viewModel = State(initialValue:)` in init
- [ ] Import `{AppName}Common` for localization
- [ ] Import `{AppName}DesignSystem` for UI components
- [ ] Use design tokens (colors, typography, spacing) - no hardcoded values
- [ ] Create new DesignSystem components if needed for complex UI
- [ ] Add private `LocalizedStrings` enum with all strings
- [ ] Delegate user actions to ViewModel methods
- [ ] Implement `body` with `.task` modifier for loading
- [ ] Implement `content` with switch on `viewModel.state`
- [ ] Handle all ViewState cases
- [ ] Add private `AccessibilityIdentifier` enum
- [ ] Add Previews for each state (except idle)
