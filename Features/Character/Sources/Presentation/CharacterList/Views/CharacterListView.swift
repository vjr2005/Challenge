import ChallengeResources
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct CharacterListView<ViewModel: CharacterListViewModelContract>: View {
	@State private var viewModel: ViewModel
	@Environment(\.dsTheme) private var theme

	init(viewModel: ViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		Group {
			if viewModel.state.isSearchAvailable {
				content
					.searchable(
						text: $viewModel.searchQuery,
						prompt: LocalizedStrings.searchPlaceholder
					)
					.searchSuggestions {
						if viewModel.searchQuery.isEmpty {
							ForEach(viewModel.recentSearches, id: \.self) { query in
								Button {
									Task {
										await viewModel.didSelectRecentSearch(query)
									}
								} label: {
									Label(query, systemImage: "clock.arrow.circlepath")
								}
								.accessibilityIdentifier(AccessibilityIdentifier.recentSearch(query: query))
								.swipeActions(edge: .trailing) {
									Button(role: .destructive) {
										viewModel.didDeleteRecentSearch(query)
									} label: {
										Label(
											LocalizedStrings.deleteAction,
											systemImage: "trash"
										)
									}
								}
							}
						}
					}
			} else {
				content
			}
		}
		.onFirstAppear {
			await viewModel.didAppear()
		}
		.navigationTitle(LocalizedStrings.title)
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				filterButton
			}
		}
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
        .padding(.vertical, theme.spacing.sm)
    }

    func footerView(page: CharactersPage) -> some View {
        Text(LocalizedStrings.pageIndicator(page.currentPage, page.totalPages))
            .font(theme.typography.caption2)
            .foregroundStyle(theme.colors.textPrimary)
            .padding(.bottom, theme.spacing.lg)
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
			LazyVStack(spacing: theme.spacing.lg) {
				headerView(totalCount: page.totalCount)

				ForEach(page.characters, id: \.id) { character in
					DSCardInfoRow(
						imageURL: character.imageURL,
						title: character.name,
						subtitle: character.species,
						caption: character.location.name,
						captionIcon: "mappin.circle.fill",
						status: DSStatus.from(character.status.rawValue),
						statusLabel: character.status.localizedName,
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
			.padding(.horizontal, theme.spacing.lg)
		}
		.refreshable {
			await viewModel.didPullToRefresh()
		}
		.accessibilityIdentifier(AccessibilityIdentifier.scrollView)
		.background(theme.colors.backgroundSecondary)
	}

	func headerView(totalCount: Int) -> some View {
		VStack(alignment: .leading, spacing: theme.spacing.xs) {
			Text(LocalizedStrings.headerTitle)
				.font(theme.typography.largeTitle)
				.foregroundStyle(theme.colors.textPrimary)

			Text(LocalizedStrings.headerSubtitle(totalCount))
				.font(theme.typography.subheadline)
				.foregroundStyle(theme.colors.textSecondary)
				.italic()
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.vertical, theme.spacing.sm)
	}

	func errorView(error: CharactersPageError) -> some View {
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

	var filterButton: some View {
		Button {
			viewModel.didTapAdvancedSearchButton()
		} label: {
			DSBadge(count: viewModel.activeFilterCount) {
				Image(systemName: "line.3.horizontal.decrease.circle")
			}
		}
		.accessibilityIdentifier(AccessibilityIdentifier.filterButton)
	}
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
	static var title: String { "characterList.title".localized() }
	static var loading: String { "characterList.loading".localized() }
	static var searchPlaceholder: String { "characterList.searchPlaceholder".localized() }
	static var headerTitle: String { "characterList.headerTitle".localized() }
	static func headerSubtitle(_ count: Int) -> String { "characterList.headerSubtitle %lld".localized(count) }
	static var deleteAction: String { "common.delete".localized() }
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
	static let filterButton = "characterList.filter.button"

	static func row(identifier: Int) -> String {
		"characterList.row.\(identifier)"
	}

	static func recentSearch(query: String) -> String {
		"characterList.recentSearch.\(query)"
	}
}
