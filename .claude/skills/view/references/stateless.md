# Stateless View

View with `let viewModel` — no `@State`, no `@Observable`, no `ViewState`. ViewModel exposes actions only (navigation, tracking). View calls sync methods directly.

Placeholders: `{Name}` (PascalCase screen), `{Feature}` (PascalCase module), `{AppName}` (app target prefix), `{screenName}` (camelCase screen for accessibility/localization keys).

---

## View

```swift
import {AppName}DesignSystem
import {AppName}Resources
import SwiftUI

struct {Name}View<ViewModel: {Name}ViewModelContract>: View {
    let viewModel: ViewModel

    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Text(LocalizedStrings.title)
                .font(theme.typography.headline)

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

## Subviews

For stateless views with more complex layouts, extract subviews the same way:

```swift
// MARK: - Subviews

private extension {Name}View {
    var headerView: some View {
        Text(LocalizedStrings.title)
            .font(theme.typography.headline)
            .foregroundStyle(theme.colors.textPrimary)
    }
}
```

## LocalizedStrings

```swift
import {AppName}Resources

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "{screenName}.title".localized() }
    static var actionButton: String { "{screenName}.actionButton".localized() }
}
```

## AccessibilityIdentifier

```swift
// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let view = "{screenName}.view"
    static let actionButton = "{screenName}.actionButton"
}
```

Format: `{screenName}.{elementType}`. Use `.accessibilityIdentifier()` for standard SwiftUI elements and `.dsAccessibilityIdentifier()` / `accessibilityIdentifier:` parameter for DS components.

## Previews

Stateless views have a **single preview** (no states to iterate). Preview stub has no `@Observable` and no state — just no-op methods.

```swift
/*
// MARK: - Previews

#Preview {
    {Name}View(viewModel: {Name}ViewModelPreviewStub())
}
*/

// MARK: - Preview Stubs

#if DEBUG
private final class {Name}ViewModelPreviewStub: {Name}ViewModelContract {
    func didAppear() {}
    func didTapOn{Action}() {}
}
#endif
```

> **Note:** No `@Observable` on preview stub — stateless ViewModels have no observable state. Wrap stubs in `#if DEBUG`.

## Snapshot Test Stub

Located at `Tests/Shared/Stubs/{Name}ViewModelStub.swift`:

```swift
import Foundation

@testable import {AppName}{Feature}

final class {Name}ViewModelStub: {Name}ViewModelContract {
    func didAppear() {}
    func didTapOn{Action}() {}
}
```

> **Note:** No `@Observable` — stub mirrors the stateless ViewModel pattern.

## Snapshot Tests

Located at `Tests/Snapshots/Presentation/{Name}/{Name}ViewSnapshotTests.swift`:

```swift
import ChallengeSnapshotTestKit
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Name}ViewSnapshotTests {
    // MARK: - Properties

    private let imageLoader: ImageLoaderMock

    // MARK: - Initialization

    init() {
        UIView.setAnimationsEnabled(false)
        imageLoader = ImageLoaderMock(cachedImage: .stub, asyncImage: .stub)
    }

    // MARK: - Tests

    @Test("Renders view correctly")
    func viewRendersCorrectly() {
        // Given
        let viewModel = {Name}ViewModelStub()

        // When
        let view = NavigationStack {
            {Name}View(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }
}
```

> **Note:** Single snapshot test — stateless views have one visual state.
