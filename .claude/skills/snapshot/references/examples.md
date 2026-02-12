# Snapshot Test Examples

Complete implementation examples for snapshot tests.

---

## CharacterDetailViewSnapshotTests

```swift
import {AppName}CoreMocks
import {AppName}SnapshotTestKit
import SwiftUI
import Testing

@testable import {AppName}Character

struct CharacterDetailViewSnapshotTests {
    private let imageLoader: ImageLoaderMock

    init() {
        UIView.setAnimationsEnabled(false)
        imageLoader = ImageLoaderMock(cachedImage: .stub, asyncImage: .stub)
    }

    @Test("Renders loading state correctly")
    func loadingState() {
        // Given
        let viewModel = CharacterDetailViewModelStub(state: .loading)

        // When
        let view = NavigationStack {
            CharacterDetailView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }

    @Test("Renders loaded state with alive character")
    func loadedStateAliveCharacter() {
        // Given
        let character = Character.stub(
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            gender: .male
        )
        let viewModel = CharacterDetailViewModelStub(state: .loaded(character))

        // When
        let view = NavigationStack {
            CharacterDetailView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }

    @Test("Renders loaded state with dead character")
    func loadedStateDeadCharacter() {
        // Given
        let character = Character.stub(
            name: "Birdperson",
            status: .dead,
            species: "Birdperson"
        )
        let viewModel = CharacterDetailViewModelStub(state: .loaded(character))

        // When
        let view = NavigationStack {
            CharacterDetailView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }

    @Test("Renders error state correctly")
    func errorState() {
        // Given
        let viewModel = CharacterDetailViewModelStub(state: .error(SnapshotTestError.loadFailed))

        // When
        let view = NavigationStack {
            CharacterDetailView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }
}

private enum SnapshotTestError: LocalizedError {
    case loadFailed

    var errorDescription: String? {
        "Failed to load character details"
    }
}
```

---

## CharacterListViewSnapshotTests

```swift
import {AppName}CoreMocks
import {AppName}SnapshotTestKit
import SwiftUI
import Testing

@testable import {AppName}Character

struct CharacterListViewSnapshotTests {
    private let imageLoader: ImageLoaderMock

    init() {
        UIView.setAnimationsEnabled(false)
        imageLoader = ImageLoaderMock(cachedImage: .stub, asyncImage: .stub)
    }

    @Test("Renders loading state correctly")
    func loadingState() {
        // Given
        let viewModel = CharacterListViewModelStub(state: .loading)

        // When
        let view = NavigationStack {
            CharacterListView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }

    @Test("Renders loaded state with characters list")
    func loadedStateWithCharacters() {
        // Given
        let page = CharactersPage.stub(
            characters: [
                .stub(id: 1, name: "Rick Sanchez", status: .alive),
                .stub(id: 2, name: "Morty Smith", status: .alive),
                .stub(id: 3, name: "Summer Smith", status: .dead)
            ]
        )
        let viewModel = CharacterListViewModelStub(state: .loaded(page))

        // When
        let view = NavigationStack {
            CharacterListView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }

    @Test("Renders empty state correctly")
    func emptyState() {
        // Given
        let viewModel = CharacterListViewModelStub(state: .empty)

        // When
        let view = NavigationStack {
            CharacterListView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }

    @Test("Renders error state correctly")
    func errorState() {
        // Given
        let viewModel = CharacterListViewModelStub(state: .error(SnapshotTestError.networkError))

        // When
        let view = NavigationStack {
            CharacterListView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
    }
}

private enum SnapshotTestError: LocalizedError {
    case networkError

    var errorDescription: String? {
        "Unable to connect to the server"
    }
}
```

---

## ViewModel Protocol

```swift
// Sources/Presentation/{Name}/ViewModels/{Name}ViewModelContract.swift
import Foundation

protocol {Name}ViewModelContract: AnyObject {
    var state: {Name}ViewState { get }
    func didAppear() async
    func didTapOnRetryButton() async
}
```

---

## ViewModel Stub

```swift
// Tests/Shared/Stubs/{Name}ViewModelStub.swift
import Foundation

@testable import {AppName}{Feature}

@Observable
final class {Name}ViewModelStub: {Name}ViewModelContract {
    var state: {Name}ViewState

    init(state: {Name}ViewState) {
        self.state = state
    }

    func didAppear() async {}
    func didTapOnRetryButton() async {}
}
```

---

## UIImage+Stub

Each module provides its own `UIImage` stub using a `BundleFinder` class. Located at `Tests/Shared/Stubs/UIImage+Stub.swift`:

```swift
import UIKit

extension UIImage {
    static var stub: UIImage? {
        let bundle = Bundle(for: {Feature}BundleFinder.self)
        guard let path = bundle.path(forResource: "test-avatar", ofType: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}

private final class {Feature}BundleFinder {}
```

---

## Generic View for Protocol

```swift
// Sources/Presentation/{Name}/Views/{Name}View.swift
struct {Name}View<ViewModel: {Name}ViewModelContract>: View {
    @State private var viewModel: ViewModel
    @Environment(\.dsTheme) private var theme

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .onFirstAppear { await viewModel.didAppear() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle: Color.clear
        case .loading: DSLoadingView(message: LocalizedStrings.loading)
        case .loaded(let data): Text(data.name)
        case .error: DSErrorView(
            title: LocalizedStrings.Error.title,
            message: LocalizedStrings.Error.description,
            retryTitle: LocalizedStrings.Common.tryAgain,
            retryAction: { Task { await viewModel.didTapOnRetryButton() } }
        )
        }
    }
}
```

---

## Component Strategy (`.component`)

For components that wrap a `Button` and need a live `UIWindow` to render correctly:

```swift
import {AppName}SnapshotTestKit
import SwiftUI
import Testing

@testable import {AppName}DesignSystem

struct DSChipSnapshotTests {
    init() {
        UIView.setAnimationsEnabled(false)
    }

    @Test("Renders unselected chip with border")
    func unselectedChip() {
        assertSnapshot(
            of: DSChip("Alive", isSelected: false) {}.padding(),
            as: .component(size: CGSize(width: 200, height: 60))
        )
    }

    @Test("Renders gallery of selected and unselected chips")
    func chipGallery() {
        let gallery = HStack(spacing: DefaultSpacing().sm) {
            DSChip("Alive", isSelected: true) {}
            DSChip("Dead", isSelected: false) {}
            DSChip("Unknown", isSelected: false) {}
        }

        assertSnapshot(
            of: gallery.padding(),
            as: .component(size: CGSize(width: 320, height: 60))
        )
    }
}
```

---

## Presentation Layer Strategy (`.presentationLayer`)

For views that animate via `CAAnimation` (e.g. Lottie), where the visible state only exists in the presentation layer:

```swift
import {AppName}SnapshotTestKit
import SwiftUI
import Testing

@testable import {AppName}Home

struct HomeViewSnapshotTests {
    init() {
        UIView.setAnimationsEnabled(false)
    }

    @Test("Renders view before animation starts")
    func beforeAnimation() {
        let view = NavigationStack {
            HomeView(viewModel: HomeViewModelStub())
        }

        assertSnapshot(of: view, as: .presentationLayer)
    }
}
```

---

## Tuist Configuration

### Test Dependencies

```swift
let characterModule = FrameworkModule.create(
    name: "Character",
    path: "Features/Character",
    dependencies: [
        .target(name: "\(appName)Core"),
    ],
    testDependencies: [
        .target(name: "\(appName)CoreMocks"),
    ]
)
```

Note: `ChallengeSnapshotTestKit` is automatically added to all snapshot test targets by `FrameworkModule.create`. No manual dependency configuration is needed. Tests must only import `ChallengeSnapshotTestKit` — never import the underlying library directly.

Mocks, Tests, and Resources targets are automatically created if the corresponding folders exist:
- `Libraries/{path}/Mocks/` with Swift files → Creates Mocks target
- `Libraries/{path}/Tests/` with Swift files → Creates Tests target
- `Libraries/{path}/Sources/Resources/` with any files → Includes resources in framework

### Test Resources

Place test resources in `Libraries/{path}/Tests/Resources/` or `Libraries/{path}/Tests/Fixtures/` - they are automatically included.
