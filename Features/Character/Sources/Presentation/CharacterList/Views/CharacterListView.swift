import ChallengeResources
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct CharacterListView<ViewModel: CharacterListViewModelContract>: View {
	@State private var viewModel: ViewModel

	init(viewModel: ViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		Group {
			if viewModel.state.isSearchAvailable {
				content
					.searchable(
						text: Binding(
							get: { viewModel.searchQuery },
							set: { viewModel.searchQuery = $0 }
						),
						prompt: LocalizedStrings.searchPlaceholder
					)
			} else {
				content
			}
		}
		.task {
			await viewModel.didAppear()
		}
		.navigationTitle(LocalizedStrings.title)
		.navigationBarTitleDisplayMode(.large)
	}
}

// MARK: - Subviews

private extension CharacterListView {
    @ViewBuilder
    var content: some View {
        switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                loadingView
            case .loaded(let page):
                characterList(page: page)
            case .empty:
                emptyView
            case .emptySearch:
                emptySearchView
            case .error(let error):
                errorView(error: error)
        }
    }

	var loadingView: some View {
		DSLoadingView(message: LocalizedStrings.loading)
	}

    var loadMoreButton: some View {
        DSButton(
            LocalizedStrings.loadMore,
            icon: "arrow.down.circle.fill",
            variant: .tertiary,
            accessibilityIdentifier: AccessibilityIdentifier.loadMoreButton
        ) {
            Task {
                await viewModel.didTapOnLoadMoreButton()
            }
        }
        .padding(.vertical, SpacingToken.sm)
    }

    func footerView(page: CharactersPage) -> some View {
        Text(LocalizedStrings.pageIndicator(page.currentPage, page.totalPages))
            .font(TextStyle.caption2.font)
            .foregroundStyle(ColorToken.textPrimary)
            .padding(.bottom, SpacingToken.lg)
    }

    var emptyView: some View {
        DSEmptyState(
            icon: "person.slash",
            title: LocalizedStrings.Empty.title,
            message: LocalizedStrings.Empty.description,
            accessibilityIdentifier: AccessibilityIdentifier.emptyState
        )
    }

    var emptySearchView: some View {
        DSEmptyState(
            icon: "magnifyingglass",
            title: LocalizedStrings.EmptySearch.title,
            message: LocalizedStrings.EmptySearch.description,
            accessibilityIdentifier: AccessibilityIdentifier.emptySearchState
        )
    }

	func characterList(page: CharactersPage) -> some View {
		ScrollView {
			LazyVStack(spacing: SpacingToken.lg) {
				headerView(totalCount: page.totalCount)

				ForEach(page.characters, id: \.id) { character in
					DSCardInfoRow(
						imageURL: character.imageURL,
						title: character.name,
						subtitle: character.species,
						caption: character.location.name,
						captionIcon: "mappin.circle.fill",
						status: DSStatus.from(character.status.rawValue),
						statusLabel: character.status.rawValue,
						accessibilityIdentifier: AccessibilityIdentifier.row(identifier: character.id)
					)
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
		.refreshable {
			await viewModel.didPullToRefresh()
		}
		.accessibilityIdentifier(AccessibilityIdentifier.scrollView)
		.background(ColorToken.backgroundSecondary)
	}

	func headerView(totalCount: Int) -> some View {
		VStack(alignment: .leading, spacing: SpacingToken.xs) {
			Text(LocalizedStrings.headerTitle)
				.font(TextStyle.largeTitle.font)
				.foregroundStyle(ColorToken.textPrimary)

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
			retryTitle: LocalizedStrings.Common.tryAgain,
			retryAction: {
				Task {
					await viewModel.didTapOnRetryButton()
				}
			},
			accessibilityIdentifier: AccessibilityIdentifier.errorView
		)
	}
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
	static var title: String { "characterList.title".localized() }
	static var loading: String { "characterList.loading".localized() }
	static var searchPlaceholder: String { "characterList.searchPlaceholder".localized() }
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

	enum EmptySearch {
		static var title: String { "characterList.emptySearch.title".localized() }
		static var description: String { "characterList.emptySearch.description".localized() }
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
	static let loadMoreButton = "characterList.loadMore.button"
	static let emptyState = "characterList.emptyState"
	static let emptySearchState = "characterList.emptySearchState"
	static let errorView = "characterList.errorView"

	static func row(identifier: Int) -> String {
		"characterList.row.\(identifier)"
	}
}

/*
// MARK: - Previews

#if DEBUG
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
@Observable
private final class CharacterListViewModelPreviewStub: CharacterListViewModelContract {
	var state: CharacterListViewState
	var searchQuery: String = ""

	init(state: CharacterListViewState) {
		self.state = state
	}

	func didAppear() async {}
	func didTapOnRetryButton() async {}
	func didPullToRefresh() async {}
	func didTapOnLoadMoreButton() async {}
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
*/
