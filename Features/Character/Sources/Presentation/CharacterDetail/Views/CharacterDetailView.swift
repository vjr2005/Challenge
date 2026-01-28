import ChallengeResources
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct CharacterDetailView<ViewModel: CharacterDetailViewModelContract>: View {
	@State private var viewModel: ViewModel

	init(viewModel: ViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		content
			.task {
				await viewModel.load()
			}
			.background(ColorToken.backgroundSecondary)
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					backButton
				}
			}
			.accessibilityIdentifier(AccessibilityIdentifier.view)
	}
}

// MARK: - Subviews

private extension CharacterDetailView {
	var backButton: some View {
		Button {
			viewModel.didTapOnBack()
		} label: {
			HStack(spacing: SpacingToken.xs) {
				Image(systemName: "chevron.left")
					.font(TextStyle.body.font.weight(.semibold))
				Text(LocalizedStrings.back)
					.font(TextStyle.body.font)
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
            retryTitle: LocalizedStrings.Common.tryAgain
        ) {
            Task {
                await viewModel.load()
            }
        }
    }

	func characterContent(_ character: Character) -> some View {
		ScrollView {
			VStack(spacing: SpacingToken.xl) {
				headerSection(character)
				infoCard(character)
				locationCard(character)
			}
			.padding(.horizontal, SpacingToken.lg)
			.padding(.top, SpacingToken.sm)
			.padding(.bottom, SpacingToken.xxl)
		}
	}

	func headerSection(_ character: Character) -> some View {
		DSCard(padding: SpacingToken.xl) {
			VStack(spacing: SpacingToken.lg) {
				characterImage(character)
				nameAndStatus(character)
			}
			.frame(maxWidth: .infinity)
		}
	}

	func characterImage(_ character: Character) -> some View {
		DSAsyncImage(url: character.imageURL) { phase in
			switch phase {
			case .success(let image):
				image
					.resizable()
					.scaledToFill()
			case .empty:
				ProgressView()
			case .failure:
				errorImage
			@unknown default:
				ProgressView()
			}
		}
		.frame(width: 150, height: 150)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.xl))
		.shadow(.medium)
	}

	var errorImage: some View {
		ZStack {
			ColorToken.surfaceSecondary
			Image(systemName: "photo")
				.font(.largeTitle)
				.foregroundStyle(ColorToken.textTertiary)
		}
	}

	func nameAndStatus(_ character: Character) -> some View {
		VStack(spacing: SpacingToken.sm) {
			DSText(character.name, style: .title)
				.multilineTextAlignment(.center)

			HStack(spacing: SpacingToken.sm) {
				DSStatusIndicator(status: DSStatus.from(character.status.rawValue), size: 10)

				Text(character.status.rawValue)
					.font(TextStyle.subheadline.font)
					.foregroundStyle(ColorToken.textSecondary)

				Text("•")
					.foregroundStyle(ColorToken.textTertiary)

				Text(character.species)
					.font(TextStyle.subheadline.font)
					.foregroundStyle(ColorToken.textSecondary)
					.italic()
			}
		}
	}

	func infoCard(_ character: Character) -> some View {
		DSCard(padding: SpacingToken.xl) {
			VStack(alignment: .leading, spacing: SpacingToken.lg) {
				DSText(LocalizedStrings.information, style: .headline)

				VStack(spacing: SpacingToken.md) {
					DSInfoRow(icon: "person.fill", label: "Gender", value: character.gender)
					Divider()
					DSInfoRow(icon: "leaf.fill", label: "Species", value: character.species)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}

	func locationCard(_ character: Character) -> some View {
		DSCard(padding: SpacingToken.xl) {
			VStack(alignment: .leading, spacing: SpacingToken.lg) {
				DSText(LocalizedStrings.locations, style: .headline)

				VStack(spacing: SpacingToken.md) {
					DSInfoRow(icon: "star.fill", label: "Origin", value: character.origin.name)
					Divider()
					DSInfoRow(icon: "mappin.circle.fill", label: "Last Known", value: character.location.name)
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
	static let view = "characterDetail.view"
	static let backButton = "characterDetail.backButton"
}

// MARK: - Previews

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
		CharacterDetailView(viewModel: CharacterDetailViewModelPreviewStub(state: .error(PreviewError.failed)))
	}
}

// MARK: - Preview Stubs

#if DEBUG
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
		gender: String = "Male"
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
