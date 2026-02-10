# How To: Create View

Create SwiftUI Views with ViewModel integration using the ViewState pattern.

## Scope & Boundaries

This guide owns **only** `Sources/Presentation/{Screen}/Views/` and its snapshot tests.

| Need | Delegate to |
|------|-------------|
| ViewModel creation | [Create ViewModel](create-viewmodel.md) |
| Design tokens & components | Design System skill |
| Snapshot tests setup | Snapshot skill |
| UI tests & robots | UI Tests skill |
| Navigation wiring | [Create Navigator](create-navigator.md) |

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- ViewModel exists (see [Create ViewModel](create-viewmodel.md))
- Design System tokens and components available

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

## Workflow

### Step 1 — Identify View Type

| Type | When | Go to |
|------|------|-------|
| Stateful | ViewModel has `@Observable` + `state` property | [Step 3a](#step-3a--stateful-view) |
| Stateless | ViewModel has actions only, no observable state | [Step 3b](#step-3b--stateless-view) |

### Step 2 — Ensure ViewModel Exists

Before creating the View, verify the required ViewModel exists in `Sources/Presentation/{Screen}/ViewModels/`.

- **ViewModel found?** → Go to Step 3
- **No ViewModel found?** → See [Create ViewModel](create-viewmodel.md) first. Return here after completion.

### Step 3 — Implement View

---

## Core Conventions

### Struct Rules

- **Generic over contract** — `<ViewModel: {Screen}ViewModelContract>` for testability
- **Stateful**: `@State private var viewModel` with `_viewModel = State(initialValue:)` in init
- **Stateless**: `let viewModel` (no `@State` needed)
- **Internal visibility** — no `public` or `private` on View struct
- **No Router in View** — delegate all actions to ViewModel

### Design System Integration

> **CRITICAL:** All views must use design tokens and DS components.

- Use design tokens (colors, typography, spacing) from `{AppName}DesignSystem`
- Use atomic components (`DSCardInfoRow`, `DSAsyncImage`, etc.)
- No hardcoded values — never use raw colors, font sizes, or spacing values

### DS Accessibility Propagation

Pass `accessibilityIdentifier:` parameter or `.dsAccessibilityIdentifier()` to DS components. Identifiers propagate to children: `.image`, `.title`, `.status` suffixes.

```swift
DSCardInfoRow(
    imageURL: item.imageURL,
    title: item.name,
    subtitle: item.species,
    status: DSStatus.from(item.status.rawValue),
    statusLabel: item.status.rawValue
)
.dsAccessibilityIdentifier(AccessibilityIdentifier.row(id: item.id))
// Creates: {screenName}.row.1, {screenName}.row.1.image, {screenName}.row.1.title, {screenName}.row.1.status
```

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

## Step 3a — Stateful View

View with `@State` ViewModel that manages `ViewState`. Uses `@Observable` ViewModel with `private(set) var state` and a `switch` in `content` to render each state.

### 1. Create View

Create `Sources/Presentation/{Screen}/Views/{Screen}View.swift`:

```swift
import {AppName}DesignSystem
import {AppName}Resources
import SwiftUI

struct {Screen}View<ViewModel: {Screen}ViewModelContract>: View {
    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .onFirstAppear {
                await viewModel.didAppear()
            }
            .navigationTitle(LocalizedStrings.title)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            loadingView
        case .loaded(let data):
            loadedView(data)
        case .empty:
            emptyView
        case .error:
            errorView
        }
    }
}
```

> **Note:** Not all ViewState enums have an `.empty` case. Adapt the `switch` to match the actual ViewState.

### 2. Create Subviews

```swift
// MARK: - Subviews

private extension {Screen}View {
    var loadingView: some View {
        ProgressView()
    }

    func loadedView(_ data: {LoadedType}) -> some View {
        ScrollView {
            // Use DS components: DSCardInfoRow, DSAsyncImage, etc.
            // Use design tokens: SpacingToken, Typography, SemanticColor
        }
        .accessibilityIdentifier(AccessibilityIdentifier.scrollView)
    }

    var emptyView: some View {
        ContentUnavailableView(
            LocalizedStrings.Empty.title,
            systemImage: "tray"
        )
        .accessibilityIdentifier(AccessibilityIdentifier.emptyState)
    }

    var errorView: some View {
        ContentUnavailableView(
            LocalizedStrings.Error.title,
            systemImage: "exclamationmark.triangle"
        ) {
            Button(LocalizedStrings.Error.retry) {
                Task { await viewModel.didTapOnRetryButton() }
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifier.errorState)
    }
}
```

### 3. Add LocalizedStrings

```swift
import {AppName}Resources

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "{screenName}.title".localized() }

    enum Empty {
        static var title: String { "{screenName}.empty.title".localized() }
        static var description: String { "{screenName}.empty.description".localized() }
    }

    enum Error {
        static var title: String { "{screenName}.error.title".localized() }
        static var retry: String { "common.tryAgain".localized() }
    }
}
```

Group related strings in nested enums. Use functions for strings with interpolation:

```swift
static func itemCount(_ count: Int) -> String {
    "{screenName}.itemCount %lld".localized(count)
}
```

### 4. Add AccessibilityIdentifier

```swift
// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "{screenName}.scrollView"
    static let emptyState = "{screenName}.emptyState"
    static let errorState = "{screenName}.errorState"

    static func row(id: Int) -> String {
        "{screenName}.row.\(id)"
    }
}
```

Format: `{screenName}.{elementType}`. Use static functions for dynamic IDs. Use `.accessibilityIdentifier()` for standard SwiftUI elements and `.dsAccessibilityIdentifier()` / `accessibilityIdentifier:` parameter for DS components.

### 5. Add Previews

Previews are **commented out** (`/* */`) to avoid negatively impacting test coverage. Keep code maintained and in sync with the View. One preview per visual state except `idle`.

```swift
/*
// MARK: - Previews

#Preview("Loading") {
    NavigationStack {
        {Screen}View(viewModel: {Screen}ViewModelPreviewStub(state: .loading))
    }
}

#Preview("Loaded") {
    NavigationStack {
        {Screen}View(viewModel: {Screen}ViewModelPreviewStub(state: .loaded(.previewStub())))
    }
}

#Preview("Empty") {
    NavigationStack {
        {Screen}View(viewModel: {Screen}ViewModelPreviewStub(state: .empty))
    }
}

#Preview("Error") {
    NavigationStack {
        {Screen}View(viewModel: {Screen}ViewModelPreviewStub(state: .error(PreviewError.failed)))
    }
}
*/

// MARK: - Preview Stubs

#if DEBUG
@Observable
private final class {Screen}ViewModelPreviewStub: {Screen}ViewModelContract {
    var state: {Screen}ViewState

    init(state: {Screen}ViewState) {
        self.state = state
    }

    func didAppear() async {}
    func didTapOnRetryButton() async {}
    // Add other protocol methods as no-ops
}

private extension {Name} {
    static func previewStub(
        id: Int = 1,
        name: String = "Sample Name"
        // Add other properties with defaults
    ) -> {Name} {
        {Name}(id: id, name: name)
    }
}

private enum PreviewError: LocalizedError {
    case failed
    var errorDescription: String? { "Failed to load" }
}
#endif
```

> **Note:** Wrap preview stubs in `#if DEBUG` to exclude from release builds. The `#Preview` macro is already excluded by the compiler.

### 6. Create Snapshot Test Stub

Create `Tests/Shared/Stubs/{Screen}ViewModelStub.swift`:

```swift
import Foundation

@testable import {AppName}{Feature}

@Observable
final class {Screen}ViewModelStub: {Screen}ViewModelContract {
    var state: {Screen}ViewState

    init(state: {Screen}ViewState) {
        self.state = state
    }

    func didAppear() async {}
    func didTapOnRetryButton() async {}
    // Add other protocol methods as no-ops
}
```

### 7. Create Snapshot Tests

Create `Tests/Snapshots/Presentation/{Screen}/{Screen}ViewSnapshotTests.swift`:

```swift
import ChallengeSnapshotTestKit
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewSnapshotTests {
    // MARK: - Properties

    private let imageLoader: ImageLoaderMock

    // MARK: - Initialization

    init() {
        UIView.setAnimationsEnabled(false)
        imageLoader = ImageLoaderMock(image: SnapshotStubs.testImage)
    }

    // MARK: - Tests

    @Test("Renders loading state correctly")
    func loadingState() {
        // Given
        let viewModel = {Screen}ViewModelStub(state: .loading)

        // When
        let view = NavigationStack {
            {Screen}View(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }

    @Test("Renders loaded state correctly")
    func loadedState() {
        // Given
        let viewModel = {Screen}ViewModelStub(state: .loaded(.stub()))

        // When
        let view = NavigationStack {
            {Screen}View(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }

    @Test("Renders empty state correctly")
    func emptyState() {
        // Given
        let viewModel = {Screen}ViewModelStub(state: .empty)

        // When
        let view = NavigationStack {
            {Screen}View(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }

    @Test("Renders error state correctly")
    func errorState() {
        // Given
        let viewModel = {Screen}ViewModelStub(state: .error(.loadFailed()))

        // When
        let view = NavigationStack {
            {Screen}View(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }
}
```

> **Note:** First run creates reference images and fails (expected). Re-run to verify.

---

## Step 3b — Stateless View

View with `let viewModel` — no `@State`, no `@Observable`, no `ViewState`. ViewModel exposes actions only (navigation, tracking). View calls sync methods directly.

### 1. Create View

Create `Sources/Presentation/{Screen}/Views/{Screen}View.swift`:

```swift
import {AppName}DesignSystem
import {AppName}Resources
import SwiftUI

struct {Screen}View<ViewModel: {Screen}ViewModelContract>: View {
    let viewModel: ViewModel

    var body: some View {
        VStack(spacing: SpacingToken.lg) {
            Text(LocalizedStrings.title)
                .font(Typography.headlineLarge)

            Button(LocalizedStrings.actionButton) {
                viewModel.didTapOn{Action}()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(AccessibilityIdentifier.actionButton)
        }
        .accessibilityIdentifier(AccessibilityIdentifier.view)
        .onFirstAppear {
            viewModel.didAppear()
        }
    }
}
```

> **Note:** `.onFirstAppear` calls a **sync** method — no `await` needed for stateless ViewModels.

### 2. Add LocalizedStrings

```swift
import {AppName}Resources

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "{screenName}.title".localized() }
    static var actionButton: String { "{screenName}.actionButton".localized() }
}
```

### 3. Add AccessibilityIdentifier

```swift
// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let view = "{screenName}.view"
    static let actionButton = "{screenName}.actionButton"
}
```

### 4. Add Previews

Stateless views have a **single preview** (no states to iterate). Preview stub has no `@Observable` and no state — just no-op methods.

```swift
/*
// MARK: - Previews

#Preview {
    {Screen}View(viewModel: {Screen}ViewModelPreviewStub())
}
*/

// MARK: - Preview Stubs

#if DEBUG
private final class {Screen}ViewModelPreviewStub: {Screen}ViewModelContract {
    func didAppear() {}
    func didTapOn{Action}() {}
}
#endif
```

> **Note:** No `@Observable` on preview stub — stateless ViewModels have no observable state. Wrap stubs in `#if DEBUG`.

### 5. Create Snapshot Test Stub

Create `Tests/Shared/Stubs/{Screen}ViewModelStub.swift`:

```swift
import Foundation

@testable import {AppName}{Feature}

final class {Screen}ViewModelStub: {Screen}ViewModelContract {
    func didAppear() {}
    func didTapOn{Action}() {}
}
```

> **Note:** No `@Observable` — stub mirrors the stateless ViewModel pattern.

### 6. Create Snapshot Tests

Create `Tests/Snapshots/Presentation/{Screen}/{Screen}ViewSnapshotTests.swift`:

```swift
import ChallengeSnapshotTestKit
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewSnapshotTests {
    // MARK: - Properties

    private let imageLoader: ImageLoaderMock

    // MARK: - Initialization

    init() {
        UIView.setAnimationsEnabled(false)
        imageLoader = ImageLoaderMock(image: SnapshotStubs.testImage)
    }

    // MARK: - Tests

    @Test("Renders view correctly")
    func viewRendersCorrectly() {
        // Given
        let viewModel = {Screen}ViewModelStub()

        // When
        let view = NavigationStack {
            {Screen}View(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }
}
```

> **Note:** Single snapshot test — stateless views have one visual state.

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
- [ ] Consult design system skill before building the view
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

---

## Next steps

- [Create Navigator](create-navigator.md) — Create navigation for the screen

## See also

- [Create ViewModel](create-viewmodel.md) — ViewModel that View depends on
- [Create Feature](create-feature.md) — Feature module setup
