import ChallengeResources
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct CharacterListView<ViewModel: CharacterListViewModelContract>: View {
	@State private var viewModel: CharacterListViewModelContract

	init(viewModel: ViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		content
			.task {
				await viewModel.load()
			}
			.navigationTitle(LocalizedStrings.title)
			.navigationBarTitleDisplayMode(.large)
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.state {
		case .idle:
			Color.clear
		case .loading:
			loadingView
		case .loaded(let page):
			characterList(page: page)
		case .empty:
			emptyView
		case .error(let error):
			errorView(error: error)
		}
	}
}

// MARK: - Subviews

private extension CharacterListView {
	var loadingView: some View {
		DSLoadingView(message: LocalizedStrings.loading)
	}

    var loadMoreButton: some View {
        DSButton(
            LocalizedStrings.loadMore,
            icon: "arrow.down.circle.fill",
            variant: .tertiary
        ) {
            Task {
                await viewModel.loadMore()
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifier.loadMoreButton)
        .padding(.vertical, SpacingToken.sm)
    }

    func footerView(page: CharactersPage) -> some View {
        DSText(
            LocalizedStrings.pageIndicator(page.currentPage, page.totalPages),
            style: .caption2
        )
        .padding(.bottom, SpacingToken.lg)
    }

    var emptyView: some View {
        DSEmptyState(
            icon: "person.slash",
            title: LocalizedStrings.Empty.title,
            message: LocalizedStrings.Empty.description
        )
    }

	func characterList(page: CharactersPage) -> some View {
		ScrollView {
			LazyVStack(spacing: SpacingToken.lg) {
				headerView(totalCount: page.totalCount)

				ForEach(page.characters, id: \.id) { character in
					CharacterRowView(character: character)
						.accessibilityIdentifier(AccessibilityIdentifier.row(id: character.id))
						.onTapGesture {
							viewModel.didSelect(character)
						}
				}

				if page.hasNextPage {
					loadMoreButton
				}

				footerView(page: page)
			}
			.padding(.horizontal, SpacingToken.lg)
		}
		.accessibilityIdentifier(AccessibilityIdentifier.scrollView)
		.background(ColorToken.backgroundSecondary)
	}

	func headerView(totalCount: Int) -> some View {
		VStack(alignment: .leading, spacing: SpacingToken.xs) {
			DSText(LocalizedStrings.headerTitle, style: .largeTitle)

			Text(LocalizedStrings.headerSubtitle(totalCount))
				.font(TextStyle.subheadline.font)
				.foregroundStyle(ColorToken.textSecondary)
				.italic()
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.vertical, SpacingToken.sm)
	}

	func errorView(error: CharacterError) -> some View {
		DSErrorView(
			title: LocalizedStrings.Error.title,
			message: error.localizedDescription,
			retryTitle: LocalizedStrings.Common.tryAgain
		) {
			Task {
				await viewModel.load()
			}
		}
	}
}

// MARK: - Character Row

private struct CharacterRowView: View {
	let character: Character

	var body: some View {
		DSCard(padding: SpacingToken.lg) {
			HStack(spacing: SpacingToken.lg) {
				characterImage
				characterInfo
				Spacer()
				statusIndicator
			}
		}
	}

	var characterImage: some View {
		DSAsyncImage(url: character.imageURL)
			.frame(width: 70, height: 70)
			.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
	}

	var characterInfo: some View {
		VStack(alignment: .leading, spacing: SpacingToken.xs) {
			DSText(character.name, style: .headline)
				.lineLimit(1)

			Text(character.species)
				.font(TextStyle.subheadline.font)
				.foregroundStyle(ColorToken.textSecondary)

			HStack(spacing: SpacingToken.xs) {
				Image(systemName: "mappin.circle.fill")
					.font(.caption2)
				Text(character.location.name)
					.font(TextStyle.caption2.font)
			}
			.foregroundStyle(ColorToken.textTertiary)
			.lineLimit(1)
		}
	}

	var statusIndicator: some View {
		VStack(spacing: SpacingToken.xs) {
			DSStatusIndicator(status: characterStatus)

			Text(character.status.rawValue)
				.font(TextStyle.caption.font)
				.foregroundStyle(ColorToken.textSecondary)
		}
	}

	var characterStatus: DSStatus {
		DSStatus.from(character.status.rawValue)
	}
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
	static var title: String { "characterList.title".localized() }
	static var loading: String { "characterList.loading".localized() }
	static var headerTitle: String { "characterList.headerTitle".localized() }
	static func headerSubtitle(_ count: Int) -> String { "characterList.headerSubtitle %lld".localized(count) }
	static var loadMore: String { "characterList.loadMore".localized() }
	static var pageIndicator: (Int, Int) -> String = { current, total in
		"characterList.pageIndicator %lld %lld".localized(current, total)
	}

	enum Empty {
		static var title: String { "characterList.empty.title".localized() }
		static var description: String { "characterList.empty.description".localized() }
	}

	enum Error {
		static var title: String { "characterList.error.title".localized() }
	}

	enum Common {
		static var tryAgain: String { "common.tryAgain".localized() }
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

#Preview("Idle") {
    NavigationStack {
        CharacterListView(viewModel: CharacterListViewModelPreviewStub(state: .idle))
    }
}

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
		CharacterListView(viewModel: CharacterListViewModelPreviewStub(state: .error(.loadFailed)))
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
#endif
