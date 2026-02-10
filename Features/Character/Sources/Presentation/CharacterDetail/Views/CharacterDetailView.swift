import ChallengeResources
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct CharacterDetailView<ViewModel: CharacterDetailViewModelContract>: View {
	@State private var viewModel: ViewModel
	@Environment(\.dsTheme) private var theme

	init(viewModel: ViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		content
			.onFirstAppear {
				await viewModel.didAppear()
			}
			.background(theme.colors.backgroundSecondary)
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					backButton
				}
			}
	}
}

// MARK: - Subviews

private extension CharacterDetailView {
	var backButton: some View {
		Button {
			viewModel.didTapOnBack()
		} label: {
			HStack(spacing: theme.spacing.xs) {
				Image(systemName: "chevron.left")
					.font(theme.typography.body.weight(.semibold))
				Text(LocalizedStrings.back)
					.font(theme.typography.body)
			}
		}
		.accessibilityIdentifier(AccessibilityIdentifier.backButton)
	}

    @ViewBuilder
    var content: some View {
        switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                loadingView
            case .loaded(let character):
                characterContent(character)
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

	func characterContent(_ character: Character) -> some View {
		ScrollView {
			VStack(spacing: theme.spacing.xl) {
				headerSection(character)
				infoCard(character)
				locationCard(character)
				episodesCard
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

	func headerSection(_ character: Character) -> some View {
		DSCard(padding: theme.spacing.xl) {
			VStack(spacing: theme.spacing.lg) {
				characterImage(character)
				nameAndStatus(character)
			}
			.frame(maxWidth: .infinity)
		}
	}

	func characterImage(_ character: Character) -> some View {
		DSAsyncImage(url: character.imageURL)
			.frame(width: theme.dimensions.xxxxl, height: theme.dimensions.xxxxl)
			.clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.xl))
			.shadow(theme.shadow.medium)
	}

	func nameAndStatus(_ character: Character) -> some View {
		VStack(spacing: theme.spacing.sm) {
			Text(character.name)
				.font(theme.typography.title)
				.foregroundStyle(theme.colors.textPrimary)
				.multilineTextAlignment(.center)
                .accessibilityIdentifier(AccessibilityIdentifier.name)

			HStack(spacing: theme.spacing.sm) {
				DSStatusIndicator(status: DSStatus.from(character.status.rawValue), size: 10)

				Text(character.status.localizedName)
					.font(theme.typography.subheadline)
					.foregroundStyle(theme.colors.textSecondary)

				Text("•")
					.foregroundStyle(theme.colors.textTertiary)

				Text(character.species)
					.font(theme.typography.subheadline)
					.foregroundStyle(theme.colors.textSecondary)
					.italic()
			}
		}
	}

	func infoCard(_ character: Character) -> some View {
		DSCard(padding: theme.spacing.xl) {
			VStack(alignment: .leading, spacing: theme.spacing.lg) {
				Text(LocalizedStrings.information)
					.font(theme.typography.headline)
					.foregroundStyle(theme.colors.textPrimary)

				VStack(spacing: theme.spacing.md) {
					DSInfoRow(icon: "person.fill", label: "Gender", value: character.gender.localizedName)
					Divider()
					DSInfoRow(icon: "leaf.fill", label: "Species", value: character.species)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}

	func locationCard(_ character: Character) -> some View {
		DSCard(padding: theme.spacing.xl) {
			VStack(alignment: .leading, spacing: theme.spacing.lg) {
				Text(LocalizedStrings.locations)
					.font(theme.typography.headline)
					.foregroundStyle(theme.colors.textPrimary)

				VStack(spacing: theme.spacing.md) {
					DSInfoRow(icon: "star.fill", label: "Origin", value: character.origin.name)
					Divider()
					DSInfoRow(icon: "mappin.circle.fill", label: "Last Known", value: character.location.name)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}

	var episodesCard: some View {
		DSCard(padding: theme.spacing.xl) {
			VStack(alignment: .leading, spacing: theme.spacing.lg) {
				Label {
					Text(LocalizedStrings.episodes)
						.font(theme.typography.headline)
						.foregroundStyle(theme.colors.textPrimary)
				} icon: {
					Image(systemName: "film")
						.foregroundStyle(theme.colors.accent)
				}

				DSButton(
					LocalizedStrings.viewEpisodes,
					icon: "play.circle",
					variant: .tertiary,
					accessibilityIdentifier: AccessibilityIdentifier.episodesButton
				) {
					viewModel.didTapOnEpisodes()
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
	static var back: String { "characterDetail.back".localized() }
	static var loading: String { "characterDetail.loading".localized() }
	static var information: String { "characterDetail.information".localized() }
	static var locations: String { "characterDetail.locations".localized() }
	static var episodes: String { "characterDetail.episodes".localized() }
	static var viewEpisodes: String { "characterDetail.viewEpisodes".localized() }

	enum Error {
		static var title: String { "characterDetail.error.title".localized() }
		static var description: String { "characterDetail.error.description".localized() }
	}

	enum Common {
		static var tryAgain: String { "common.tryAgain".localized() }
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let scrollView = "characterDetail.scrollView"
	static let name = "characterDetail.name"
	static let backButton = "characterDetail.backButton"
	static let episodesButton = "characterDetail.episodesButton"
	static let errorView = "characterDetail.errorView"
}

/*
// MARK: - Previews

#if DEBUG
#Preview("Idle") {
    NavigationStack {
        CharacterDetailView(viewModel: CharacterDetailViewModelPreviewStub(state: .idle))
    }
}

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
		CharacterDetailView(viewModel: CharacterDetailViewModelPreviewStub(state: .error(.loadFailed())))
	}
}
private final class CharacterDetailViewModelPreviewStub: CharacterDetailViewModelContract {
	var state: CharacterDetailViewState

	init(state: CharacterDetailViewState) {
		self.state = state
	}

	func didAppear() async {}
	func didTapOnRetryButton() async {}
	func didPullToRefresh() async {}
	func didTapOnBack() {}
	func didTapOnEpisodes() {}
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
