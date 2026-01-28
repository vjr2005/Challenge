# View Examples

Complete implementation examples for SwiftUI Views.

---

## CharacterListView

```swift
// Sources/Presentation/CharacterList/Views/CharacterListView.swift
import {AppName}Resources
import SwiftUI

struct CharacterListView: View {
    @State private var viewModel: CharacterListViewModel

    init(viewModel: CharacterListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task {
                await viewModel.load()
            }
            .navigationTitle(LocalizedStrings.title)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            ProgressView()
        case .empty:
            ContentUnavailableView(
                LocalizedStrings.Empty.title,
                systemImage: "person.slash"
            )
        case .loaded(let characters):
            List(characters) { character in
                Button(character.name) {
                    viewModel.didSelect(character)
                }
            }
        case .error:
            ContentUnavailableView(
                LocalizedStrings.Error.title,
                systemImage: "exclamationmark.triangle"
            )
        }
    }
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "characterList.title".localized() }

    enum Empty {
        static var title: String { "characterList.empty.title".localized() }
    }

    enum Error {
        static var title: String { "characterList.error.title".localized() }
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "characterList.scrollView"
    static let loadMoreButton = "characterList.loadMoreButton"

    static func row(id: Int) -> String {
        "characterList.row.\(id)"
    }
}

// MARK: - Previews

#Preview("Loading") {
    NavigationStack {
        CharacterListView(viewModel: CharacterListViewModelPreviewStub(state: .loading))
    }
}

#Preview("Loaded") {
    NavigationStack {
        CharacterListView(viewModel: CharacterListViewModelPreviewStub(state: .loaded(.previewStub())))
    }
}

#Preview("Empty") {
    NavigationStack {
        CharacterListView(viewModel: CharacterListViewModelPreviewStub(state: .empty))
    }
}

#Preview("Error") {
    NavigationStack {
        CharacterListView(viewModel: CharacterListViewModelPreviewStub(state: .error(PreviewError.failed)))
    }
}

// MARK: - Preview Stubs

#if DEBUG
@Observable
private final class CharacterListViewModelPreviewStub: CharacterListViewModelContract {
    var state: CharacterListViewState

    init(state: CharacterListViewState) {
        self.state = state
    }

    func load() async {}
    func loadMore() async {}
    func didSelect(_ character: Character) {}
}

private extension CharactersPage {
    static func previewStub() -> CharactersPage {
        CharactersPage(
            characters: [
                .previewStub(id: 1, name: "Rick Sanchez", status: .alive),
                .previewStub(id: 2, name: "Morty Smith", status: .alive),
                .previewStub(id: 3, name: "Summer Smith", status: .dead)
            ],
            currentPage: 1,
            totalPages: 42,
            totalCount: 826,
            hasNextPage: true,
            hasPreviousPage: false
        )
    }
}

private extension Character {
    static func previewStub(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: CharacterStatus = .alive,
        species: String = "Human",
        gender: CharacterGender = .male
    ) -> Character {
        Character(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: gender,
            origin: Location(name: "Earth (C-137)", url: nil),
            location: Location(name: "Citadel of Ricks", url: nil),
            imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg")
        )
    }
}

private enum PreviewError: LocalizedError {
    case failed
    var errorDescription: String? { "Failed to load characters" }
}
#endif
```

---

## CharacterDetailView

```swift
// Sources/Presentation/CharacterDetail/Views/CharacterDetailView.swift
import {AppName}Resources
import SwiftUI

struct CharacterDetailView: View {
    @State private var viewModel: CharacterDetailViewModel

    init(viewModel: CharacterDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            ProgressView()
        case .loaded(let character):
            ScrollView {
                VStack(spacing: 16) {
                    AsyncImage(url: character.imageURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 200, height: 200)

                    Text(character.name)
                        .font(.title)
                    Text(character.status.rawValue)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        case .error:
            ContentUnavailableView(
                LocalizedStrings.Error.title,
                systemImage: "exclamationmark.triangle"
            )
        }
    }
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var loading: String { "characterDetail.loading".localized() }

    enum Error {
        static var title: String { "characterDetail.error.title".localized() }
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "characterDetail.scrollView"
    static let image = "characterDetail.image"
    static let nameLabel = "characterDetail.nameLabel"
    static let statusLabel = "characterDetail.statusLabel"
}

// MARK: - Previews

#Preview("Loading") {
    NavigationStack {
        CharacterDetailView(viewModel: CharacterDetailViewModelPreviewStub(state: .loading))
    }
}

#Preview("Loaded") {
    NavigationStack {
        CharacterDetailView(viewModel: CharacterDetailViewModelPreviewStub(state: .loaded(.previewStub())))
    }
}

#Preview("Error") {
    NavigationStack {
        CharacterDetailView(viewModel: CharacterDetailViewModelPreviewStub(state: .error(PreviewError.failed)))
    }
}

// MARK: - Preview Stubs

#if DEBUG
@Observable
private final class CharacterDetailViewModelPreviewStub: CharacterDetailViewModelContract {
    var state: CharacterDetailViewState

    init(state: CharacterDetailViewState) {
        self.state = state
    }

    func load() async {}
    func didTapOnBack() {}
}

private extension Character {
    static func previewStub(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: CharacterStatus = .alive,
        species: String = "Human",
        gender: CharacterGender = .male
    ) -> Character {
        Character(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: gender,
            origin: Location(name: "Earth (C-137)", url: nil),
            location: Location(name: "Citadel of Ricks", url: nil),
            imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg")
        )
    }
}

private enum PreviewError: LocalizedError {
    case failed
    var errorDescription: String? { "Failed to load" }
}
#endif
```

---

## HomeView (Stateless)

Stateless views (no ViewState) still use ViewModel contracts for consistency:

```swift
// Sources/Presentation/Home/Views/HomeView.swift
import {AppName}Resources
import SwiftUI

struct HomeView<ViewModel: HomeViewModelContract>: View {
    let viewModel: ViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text(LocalizedStrings.title)
                .font(.largeTitle)

            Button(LocalizedStrings.goToCharacters) {
                viewModel.didTapOnCharacterButton()
            }
            .buttonStyle(.borderedProminent)
        }
        .accessibilityIdentifier(AccessibilityIdentifier.view)
    }
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "home.title".localized() }
    static var goToCharacters: String { "home.goToCharacters".localized() }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let view = "home.view"
    static let charactersButton = "home.charactersButton"
}

// MARK: - Previews

#Preview {
    HomeView(viewModel: HomeViewModelPreviewStub())
}

// MARK: - Preview Stubs

#if DEBUG
private final class HomeViewModelPreviewStub: HomeViewModelContract {
    func didTapOnCharacterButton() {}
}
#endif
```

```swift
// Sources/Presentation/Home/ViewModels/HomeViewModelContract.swift
import Foundation

protocol HomeViewModelContract {
    func didTapOnCharacterButton()
}
```

```swift
// Sources/Presentation/Home/ViewModels/HomeViewModel.swift

final class HomeViewModel: HomeViewModelContract {
    private let navigator: HomeNavigatorContract

    init(navigator: HomeNavigatorContract) {
        self.navigator = navigator
    }

    func didTapOnCharacterButton() {
        navigator.navigateToCharacters()
    }
}
```

---

## View with List and Accessibility

```swift
struct CharacterListView: View {
    @State private var viewModel: CharacterListViewModel

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.characters) { character in
                    CharacterRowView(character: character)
                        .accessibilityIdentifier(AccessibilityIdentifier.row(id: character.id))
                        .onTapGesture {
                            viewModel.didSelect(character)
                        }
                }
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifier.scrollView)
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "characterList.scrollView"
    static let loadMoreButton = "characterList.loadMoreButton"

    static func row(id: Int) -> String {
        "characterList.row.\(id)"
    }
}
```
