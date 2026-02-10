import ChallengeDesignSystem
import ChallengeResources
import SwiftUI

struct CharacterEpisodesView<ViewModel: CharacterEpisodesViewModelContract>: View {
	// MARK: - Properties

	@State private var viewModel: ViewModel
	@Environment(\.dsTheme) private var theme

	// MARK: - Init

	init(viewModel: ViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	// MARK: - Body

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

private extension CharacterEpisodesView {
	@ViewBuilder
	var content: some View {
		switch viewModel.state {
		case .idle:
			Color.clear
		case .loading:
			loadingView
		case .loaded(let data):
			loadedView(data)
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
					await viewModel.didTapOnRetryButton()
				}
			},
			accessibilityIdentifier: AccessibilityIdentifier.errorView
		)
	}

	func loadedView(_ data: EpisodeCharacterWithEpisodes) -> some View {
		ScrollView {
			VStack(spacing: theme.spacing.xl) {
				headerSection(data)
				episodesList(data.episodes)
			}
			.padding(.horizontal, theme.spacing.lg)
			.padding(.top, theme.spacing.sm)
			.padding(.bottom, theme.spacing.xxl)
		}
		.refreshable {
			await viewModel.didPullToRefresh()
		}
		.accessibilityIdentifier(AccessibilityIdentifier.scrollView)
	}

	func headerSection(_ data: EpisodeCharacterWithEpisodes) -> some View {
		DSCard(padding: theme.spacing.xl) {
			VStack(spacing: theme.spacing.lg) {
				DSAsyncImage(url: data.imageURL, accessibilityIdentifier: AccessibilityIdentifier.headerImage)
					.frame(width: 120, height: 120)
					.clipShape(Circle())
					.shadow(theme.shadow.medium)

				Text(data.name)
					.font(theme.typography.title)
					.foregroundStyle(theme.colors.textPrimary)
					.multilineTextAlignment(.center)
					.accessibilityIdentifier(AccessibilityIdentifier.headerName)
			}
			.frame(maxWidth: .infinity)
		}
	}

	func episodesList(_ episodes: [Episode]) -> some View {
		LazyVStack(spacing: theme.spacing.lg) {
			ForEach(episodes, id: \.id) { episode in
				episodeCard(episode)
			}
		}
	}

	func episodeCard(_ episode: Episode) -> some View {
		DSCard(padding: theme.spacing.lg) {
			VStack(alignment: .leading, spacing: theme.spacing.md) {
				Text(episode.episode)
					.font(theme.typography.caption2)
					.foregroundStyle(theme.colors.accent)

				Text(episode.name)
					.font(theme.typography.headline)
					.foregroundStyle(theme.colors.textPrimary)

				DSInfoRow(icon: "calendar", label: LocalizedStrings.episodes, value: episode.airDate)

				if !episode.characters.isEmpty {
					VStack(alignment: .leading, spacing: theme.spacing.sm) {
						Text(LocalizedStrings.characters)
							.font(theme.typography.caption)
							.foregroundStyle(theme.colors.textSecondary)

						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: theme.spacing.md) {
								ForEach(episode.characters, id: \.id) { character in
									characterAvatar(character)
								}
							}
						}
					}
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.accessibilityIdentifier(AccessibilityIdentifier.episodeCard(id: episode.id))
	}

	func characterAvatar(_ character: EpisodeCharacter) -> some View {
		VStack(spacing: theme.spacing.xs) {
			DSAsyncImage(url: character.imageURL, accessibilityIdentifier: AccessibilityIdentifier.characterAvatar(id: character.id))
				.frame(width: 48, height: 48)
				.clipShape(Circle())

			Text(character.name)
				.font(theme.typography.caption2)
				.foregroundStyle(theme.colors.textSecondary)
				.lineLimit(2)
				.multilineTextAlignment(.center)
				.frame(width: 56)
		}
	}
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
	static var title: String { "characterEpisodes.title".localized() }
	static var loading: String { "characterEpisodes.loading".localized() }
	static var episodes: String { "characterEpisodes.episodes".localized() }
	static var characters: String { "characterEpisodes.characters".localized() }

	enum Error {
		static var title: String { "characterEpisodes.error.title".localized() }
		static var description: String { "characterEpisodes.error.description".localized() }
	}

	enum Common {
		static var tryAgain: String { "common.tryAgain".localized() }
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let scrollView = "characterEpisodes.scrollView"
	static let headerImage = "characterEpisodes.headerImage"
	static let headerName = "characterEpisodes.headerName"
	static let errorView = "characterEpisodes.errorView"

	static func episodeCard(id: Int) -> String {
		"characterEpisodes.episode.\(id)"
	}

	static func characterAvatar(id: Int) -> String {
		"characterEpisodes.character.\(id)"
	}
}

/*
// MARK: - Previews

#if DEBUG
#Preview("Idle") {
	NavigationStack {
		CharacterEpisodesView(viewModel: CharacterEpisodesViewModelPreviewStub(state: .idle))
	}
}

#Preview("Loading") {
	NavigationStack {
		CharacterEpisodesView(viewModel: CharacterEpisodesViewModelPreviewStub(state: .loading))
	}
}

#Preview("Loaded") {
	NavigationStack {
		CharacterEpisodesView(viewModel: CharacterEpisodesViewModelPreviewStub(state: .loaded(.previewStub())))
	}
}

#Preview("Error") {
	NavigationStack {
		CharacterEpisodesView(viewModel: CharacterEpisodesViewModelPreviewStub(state: .error(.loadFailed())))
	}
}

@Observable
private final class CharacterEpisodesViewModelPreviewStub: CharacterEpisodesViewModelContract {
	var state: CharacterEpisodesViewState

	init(state: CharacterEpisodesViewState) {
		self.state = state
	}

	func didAppear() async {}
	func didTapOnRetryButton() async {}
	func didPullToRefresh() async {}
}

private extension EpisodeCharacterWithEpisodes {
	static func previewStub() -> EpisodeCharacterWithEpisodes {
		EpisodeCharacterWithEpisodes(
			id: 1,
			name: "Rick Sanchez",
			imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
			episodes: [
				Episode(
					id: 1,
					name: "Pilot",
					airDate: "December 2, 2013",
					episode: "S01E01",
					characters: [
						EpisodeCharacter(id: 1, name: "Rick Sanchez", imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")),
						EpisodeCharacter(id: 2, name: "Morty Smith", imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg"))
					]
				),
				Episode(
					id: 2,
					name: "Lawnmower Dog",
					airDate: "December 9, 2013",
					episode: "S01E02",
					characters: [
						EpisodeCharacter(id: 1, name: "Rick Sanchez", imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"))
					]
				)
			]
		)
	}
}
#endif
*/
