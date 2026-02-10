# Stateful View

View with `@State` ViewModel that manages `ViewState`. Uses `@Observable` ViewModel with `private(set) var state` and a `switch` in `content` to render each state.

Placeholders: `{Name}` (PascalCase entity), `{Screen}` (PascalCase screen), `{Feature}` (PascalCase module), `{AppName}` (app target prefix), `{screenName}` (camelCase screen for accessibility/localization keys).

---

## View

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

## Subviews

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

## DS Accessibility Propagation

When passing `accessibilityIdentifier:` to DS components (e.g., `DSCardInfoRow`), identifiers propagate to children with suffixes:

| DS Component | Suffix |
|---|---|
| `DSAsyncImage` | `.image` |
| Title text | `.title` |
| `DSStatusIndicator` | `.status` |

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

## LocalizedStrings

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

## AccessibilityIdentifier

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

## Previews

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

## Snapshot Test Stub

Located at `Tests/Shared/Stubs/{Screen}ViewModelStub.swift`:

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

## Snapshot Tests

Located at `Tests/Snapshots/Presentation/{Screen}/{Screen}ViewSnapshotTests.swift`:

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
