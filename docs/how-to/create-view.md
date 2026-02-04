# How To: Create View

Create SwiftUI Views with ViewModel integration using the ViewState pattern.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- ViewModel exists (see [Create ViewModel](create-viewmodel.md))
- Design System tokens and components available

## File structure

```
Features/{Feature}/
├── Sources/
│   └── Presentation/
│       └── {ScreenName}/
│           └── Views/
│               └── {ScreenName}View.swift
└── Tests/
    └── Snapshots/
        └── {ScreenName}/
            └── {ScreenName}SnapshotTests.swift
```

---

## Option A: Stateful View (with ViewState)

For Views that display data with loading/error states.

### 1. Create View

Create `Sources/Presentation/{ScreenName}/Views/{ScreenName}View.swift`:

```swift
import ChallengeResources
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct {ScreenName}View<ViewModel: {ScreenName}ViewModelContract>: View {
    @State private var viewModel: ViewModel
    @Environment(\.dsTheme) private var theme

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .onFirstAppear {
                await viewModel.didAppear()
            }
            .background(theme.colors.backgroundSecondary)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews

private extension {ScreenName}View {
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            loadingView
        case .loaded(let data):
            loadedContent(data)
        case .error:
            errorView
        }
    }

    var loadingView: some View {
        DSLoadingView(message: LocalizedStrings.loading)
    }

    var errorView: some View {
        DSErrorView(
            title: LocalizedStrings.Error.title,
            message: LocalizedStrings.Error.description,
            retryTitle: LocalizedStrings.Common.tryAgain,
            retryAction: {
                Task {
                    await viewModel.didAppear()
                }
            },
            accessibilityIdentifier: AccessibilityIdentifier.errorView
        )
    }

    func loadedContent(_ data: {Name}) -> some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                // Content using Design System components
                Text(data.name)
                    .font(theme.typography.font(for: .title))
                    .foregroundStyle(theme.colors.textPrimary)
            }
            .padding(.horizontal, theme.spacing.lg)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .accessibilityIdentifier(AccessibilityIdentifier.scrollView)
    }
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var loading: String { "{screenName}.loading".localized() }

    enum Error {
        static var title: String { "{screenName}.error.title".localized() }
        static var description: String { "{screenName}.error.description".localized() }
    }

    enum Common {
        static var tryAgain: String { "common.tryAgain".localized() }
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "{screenName}.scrollView"
    static let errorView = "{screenName}.errorView"
}

/*
// MARK: - Previews

#if DEBUG
#Preview("Loading") {
    NavigationStack {
        {ScreenName}View(viewModel: {ScreenName}ViewModelPreviewStub(state: .loading))
    }
}

#Preview("Loaded") {
    NavigationStack {
        {ScreenName}View(viewModel: {ScreenName}ViewModelPreviewStub(state: .loaded(.previewStub())))
    }
}

#Preview("Error") {
    NavigationStack {
        {ScreenName}View(viewModel: {ScreenName}ViewModelPreviewStub(state: .error(.loadFailed)))
    }
}

private final class {ScreenName}ViewModelPreviewStub: {ScreenName}ViewModelContract {
    var state: {ScreenName}ViewState

    init(state: {ScreenName}ViewState) {
        self.state = state
    }

    func didAppear() async {}
    func refresh() async {}
    func didTapOnBack() {}
}

private extension {Name} {
    static func previewStub(
        id: Int = 1,
        name: String = "Sample Name"
    ) -> {Name} {
        {Name}(id: id, name: name)
    }
}
#endif
*/
```

**Key patterns:**
- Generic over `ViewModel: {ScreenName}ViewModelContract` for testability
- `@State private var viewModel` with `_viewModel = State(initialValue:)` in init
- `.onFirstAppear { await viewModel.didAppear() }` for initial load (executes only once)
- Switch on `viewModel.state` for all ViewState cases
- Use Design System tokens via `@Environment(\.dsTheme)` (theme.colors, theme.typography, theme.spacing)
- Private `LocalizedStrings` enum for localization
- Private `AccessibilityIdentifier` enum for UI testing
- Previews commented out to avoid test coverage impact

---

## Option B: List View

For Views that display lists with item selection.

### 1. Create View

Create `Sources/Presentation/{ScreenName}/Views/{ScreenName}View.swift`:

```swift
import ChallengeResources
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct {ScreenName}View<ViewModel: {ScreenName}ViewModelContract>: View {
    @State private var viewModel: ViewModel
    @Environment(\.dsTheme) private var theme

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .onFirstAppear {
                await viewModel.didAppear()
            }
            .background(theme.colors.backgroundSecondary)
            .navigationTitle(LocalizedStrings.title)
    }
}

// MARK: - Subviews

private extension {ScreenName}View {
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            loadingView
        case .loaded(let page):
            listContent(page.items)
        case .empty:
            emptyView
        case .error:
            errorView
        }
    }

    var loadingView: some View {
        DSLoadingView(message: LocalizedStrings.loading)
    }

    var emptyView: some View {
        ContentUnavailableView(
            LocalizedStrings.Empty.title,
            systemImage: "tray",
            description: Text(LocalizedStrings.Empty.description)
        )
        .accessibilityIdentifier(AccessibilityIdentifier.emptyView)
    }

    var errorView: some View {
        DSErrorView(
            title: LocalizedStrings.Error.title,
            message: LocalizedStrings.Error.description,
            retryTitle: LocalizedStrings.Common.tryAgain,
            retryAction: {
                Task {
                    await viewModel.didAppear()
                }
            },
            accessibilityIdentifier: AccessibilityIdentifier.errorView
        )
    }

    func listContent(_ items: [{Name}]) -> some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.md) {
                ForEach(items) { item in
                    itemRow(item)
                }
            }
            .padding(.horizontal, theme.spacing.lg)
        }
        .accessibilityIdentifier(AccessibilityIdentifier.scrollView)
    }

    func itemRow(_ item: {Name}) -> some View {
        Button {
            viewModel.didSelect(item)
        } label: {
            DSCardInfoRow(
                imageURL: item.imageURL,
                title: item.name,
                accessibilityIdentifier: AccessibilityIdentifier.row(id: item.id)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "{screenName}.title".localized() }
    static var loading: String { "{screenName}.loading".localized() }

    enum Empty {
        static var title: String { "{screenName}.empty.title".localized() }
        static var description: String { "{screenName}.empty.description".localized() }
    }

    enum Error {
        static var title: String { "{screenName}.error.title".localized() }
        static var description: String { "{screenName}.error.description".localized() }
    }

    enum Common {
        static var tryAgain: String { "common.tryAgain".localized() }
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "{screenName}.scrollView"
    static let emptyView = "{screenName}.emptyView"
    static let errorView = "{screenName}.errorView"

    static func row(id: Int) -> String {
        "{screenName}.row.\(id)"
    }
}

/*
// MARK: - Previews

#if DEBUG
#Preview("Loading") {
    NavigationStack {
        {ScreenName}View(viewModel: {ScreenName}ViewModelPreviewStub(state: .loading))
    }
}

#Preview("Loaded") {
    NavigationStack {
        {ScreenName}View(viewModel: {ScreenName}ViewModelPreviewStub(state: .loaded(.previewStub())))
    }
}

#Preview("Empty") {
    NavigationStack {
        {ScreenName}View(viewModel: {ScreenName}ViewModelPreviewStub(state: .empty))
    }
}

#Preview("Error") {
    NavigationStack {
        {ScreenName}View(viewModel: {ScreenName}ViewModelPreviewStub(state: .error(.loadFailed)))
    }
}

private final class {ScreenName}ViewModelPreviewStub: {ScreenName}ViewModelContract {
    var state: {ScreenName}ViewState

    init(state: {ScreenName}ViewState) {
        self.state = state
    }

    func didAppear() async {}
    func didSelect(_ item: {Name}) {}
}

private extension {Name}sPage {
    static func previewStub() -> {Name}sPage {
        {Name}sPage(items: [
            {Name}(id: 1, name: "Item 1"),
            {Name}(id: 2, name: "Item 2"),
            {Name}(id: 3, name: "Item 3")
        ])
    }
}
#endif
*/
```

---

## Option C: Stateless View (navigation only)

For Views with no observable state, only navigation actions.

### 1. Create View

Create `Sources/Presentation/{ScreenName}/Views/{ScreenName}View.swift`:

```swift
import ChallengeResources
import ChallengeDesignSystem
import SwiftUI

struct {ScreenName}View<ViewModel: {ScreenName}ViewModelContract>: View {
    let viewModel: ViewModel

    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Text(LocalizedStrings.title)
                .font(theme.typography.font(for: .title))
                .foregroundStyle(theme.colors.textPrimary)

            Button(LocalizedStrings.actionButton) {
                viewModel.didTapOn{Action}()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(AccessibilityIdentifier.actionButton)
        }
        .padding(theme.spacing.lg)
    }
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "{screenName}.title".localized() }
    static var actionButton: String { "{screenName}.actionButton".localized() }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let actionButton = "{screenName}.actionButton"
}

/*
// MARK: - Previews

#if DEBUG
#Preview("{ScreenName}") {
    {ScreenName}View(viewModel: {ScreenName}ViewModelPreviewStub())
}

private final class {ScreenName}ViewModelPreviewStub: {ScreenName}ViewModelContract {
    func didTapOn{Action}() {}
}
#endif
*/
```

**Key patterns:**
- `let viewModel` instead of `@State private var viewModel`
- No `.onFirstAppear` modifier (no async data loading)
- ViewModel only has action methods

---

## Design System Integration

All Views must use Design System components and tokens:

| Type | Usage |
|------|-------|
| **Colors** | `theme.colors.textPrimary`, `theme.colors.backgroundSecondary` |
| **Typography** | `theme.typography.font(for: .title)`, `theme.typography.font(for: .body)` |
| **Spacing** | `theme.spacing.lg`, `theme.spacing.md`, `theme.spacing.sm` |
| **CornerRadiusToken** | `CornerRadiusToken.lg`, `CornerRadiusToken.md` |
| **DS Components** | `DSCard`, `DSAsyncImage`, `DSLoadingView`, `DSErrorView` |

```swift
@Environment(\.dsTheme) private var theme

// ✅ Correct - using design system
Text(item.name)
    .font(theme.typography.font(for: .body))
    .foregroundStyle(theme.colors.textPrimary)
    .padding(theme.spacing.md)    // via @Environment(\.dsTheme)

// ❌ Wrong - hardcoded values
Text(item.name)
    .font(.system(size: 16))
    .foregroundStyle(.black)
    .padding(16)
```

---

## Generate and verify

```bash
./generate.sh
```

## Next steps

- [Create Navigator](create-navigator.md) - Create navigation for the screen

## See also

- [Create ViewModel](create-viewmodel.md) - ViewModel that View depends on
- [Testing](../Testing.md) - Testing documentation
- [Project Structure](../ProjectStructure.md)
