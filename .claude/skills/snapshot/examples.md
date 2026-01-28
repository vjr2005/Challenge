# Snapshot Test Examples

Complete implementation examples for snapshot tests.

---

## CharacterDetailViewSnapshotTests

```swift
import {AppName}CoreMocks
import SnapshotTesting
import SwiftUI
import Testing

@testable import {AppName}Character

struct CharacterDetailViewSnapshotTests {
    private let imageLoader: ImageLoaderMock

    init() {
        UIView.setAnimationsEnabled(false)
        imageLoader = ImageLoaderMock(image: SnapshotStubs.testImage)
    }

    @Test
    func loadingState() {
        // Given
        let viewModel = CharacterDetailViewModelStub(state: .loading)

        // When
        let view = NavigationStack {
            CharacterDetailView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
    }

    @Test
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
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
    }

    @Test
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
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
    }

    @Test
    func errorState() {
        // Given
        let viewModel = CharacterDetailViewModelStub(state: .error(SnapshotTestError.loadFailed))

        // When
        let view = NavigationStack {
            CharacterDetailView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
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
import SnapshotTesting
import SwiftUI
import Testing

@testable import {AppName}Character

struct CharacterListViewSnapshotTests {
    private let imageLoader: ImageLoaderMock

    init() {
        UIView.setAnimationsEnabled(false)
        imageLoader = ImageLoaderMock(image: SnapshotStubs.testImage)
    }

    @Test
    func loadingState() {
        // Given
        let viewModel = CharacterListViewModelStub(state: .loading)

        // When
        let view = NavigationStack {
            CharacterListView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
    }

    @Test
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
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
    }

    @Test
    func emptyState() {
        // Given
        let viewModel = CharacterListViewModelStub(state: .empty)

        // When
        let view = NavigationStack {
            CharacterListView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
    }

    @Test
    func errorState() {
        // Given
        let viewModel = CharacterListViewModelStub(state: .error(SnapshotTestError.networkError))

        // When
        let view = NavigationStack {
            CharacterListView(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
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
    func load() async
}
```

---

## ViewModel Stub

```swift
// Tests/Presentation/Helpers/{Name}ViewModelStub.swift
import Foundation

@testable import {AppName}{Feature}

@Observable
final class {Name}ViewModelStub: {Name}ViewModelContract {
    var state: {Name}ViewState

    init(state: {Name}ViewState) {
        self.state = state
    }

    func load() async { }
}
```

---

## SnapshotStubs

```swift
// Tests/Presentation/Helpers/SnapshotStubs.swift
import Foundation
import UIKit

enum SnapshotStubs {
    static var testImage: UIImage? {
        guard let path = Bundle.module.path(forResource: "test-avatar", ofType: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}
```

---

## Generic View for Protocol

```swift
// Sources/Presentation/{Name}/Views/{Name}View.swift
struct {Name}View<ViewModel: {Name}ViewModelContract>: View {
    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
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
        .external(name: "SnapshotTesting"),
    ]
)
```

Note: Mocks, Tests, and Resources targets are automatically created if the corresponding folders exist:
- `Libraries/{path}/Mocks/` with Swift files → Creates Mocks target
- `Libraries/{path}/Tests/` with Swift files → Creates Tests target
- `Libraries/{path}/Sources/Resources/` with any files → Includes resources in framework

### Test Resources

Place test resources in `Libraries/{path}/Tests/Resources/` or `Libraries/{path}/Tests/Fixtures/` - they are automatically included.
