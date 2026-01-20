# View Examples

Complete implementation examples for SwiftUI Views.

---

## CharacterListView

```swift
// Sources/Presentation/CharacterList/Views/CharacterListView.swift
import ChallengeCommon
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
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(delay: true),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Loaded") {
    NavigationStack {
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(isEmpty: true),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Error") {
    NavigationStack {
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(shouldFail: true),
                router: RouterPreviewMock()
            )
        )
    }
}

// MARK: - Preview Mocks

private final class GetCharactersUseCasePreviewMock: GetCharactersUseCaseContract {
    private let delay: Bool
    private let isEmpty: Bool
    private let shouldFail: Bool

    init(delay: Bool = false, isEmpty: Bool = false, shouldFail: Bool = false) {
        self.delay = delay
        self.isEmpty = isEmpty
        self.shouldFail = shouldFail
    }

    func execute() async throws -> [Character] {
        if delay {
            try? await Task.sleep(for: .seconds(100))
        }
        if shouldFail {
            throw PreviewError.failed
        }
        if isEmpty {
            return []
        }
        return [Character.stub()]
    }
}

private enum PreviewError: Error {
    case failed
}

private final class RouterPreviewMock: RouterContract {
    func navigate(to destination: any Navigation) {}
    func goBack() {}
}
```

---

## CharacterDetailView

```swift
// Sources/Presentation/CharacterDetail/Views/CharacterDetailView.swift
import ChallengeCommon
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
        CharacterDetailView(
            viewModel: CharacterDetailViewModel(
                identifier: 1,
                getCharacterUseCase: GetCharacterUseCasePreviewMock(delay: true),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Loaded") {
    NavigationStack {
        CharacterDetailView(
            viewModel: CharacterDetailViewModel(
                identifier: 1,
                getCharacterUseCase: GetCharacterUseCasePreviewMock(),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Error") {
    NavigationStack {
        CharacterDetailView(
            viewModel: CharacterDetailViewModel(
                identifier: 1,
                getCharacterUseCase: GetCharacterUseCasePreviewMock(shouldFail: true),
                router: RouterPreviewMock()
            )
        )
    }
}

// MARK: - Preview Mocks

private final class GetCharacterUseCasePreviewMock: GetCharacterUseCaseContract {
    private let delay: Bool
    private let shouldFail: Bool

    init(delay: Bool = false, shouldFail: Bool = false) {
        self.delay = delay
        self.shouldFail = shouldFail
    }

    func execute(identifier: Int) async throws -> Character {
        if delay {
            try? await Task.sleep(for: .seconds(100))
        }
        if shouldFail {
            throw PreviewError.failed
        }
        return Character.stub()
    }
}

private enum PreviewError: Error {
    case failed
}

private final class RouterPreviewMock: RouterContract {
    func navigate(to destination: any Navigation) {}
    func goBack() {}
}
```

---

## HomeView (Stateless)

Stateless views (no ViewState) need only one preview:

```swift
// Sources/Presentation/Home/Views/HomeView.swift
import ChallengeCommon
import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel

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
    NavigationStack {
        HomeView(viewModel: HomeViewModel(router: RouterPreviewMock()))
    }
}

// MARK: - Preview Mocks

private final class RouterPreviewMock: RouterContract {
    func navigate(to destination: any Navigation) {}
    func goBack() {}
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
