import ChallengeCommon
import ChallengeCore
import ChallengeDesignSystem
import SwiftUI

struct CharacterListView<ViewModel: CharacterListViewModelContract>: View {
	@State private var viewModel: ViewModel

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

	func errorView(error: Error) -> some View {
		DSErrorView(
			title: LocalizedStrings.Error.title,
			message: error.localizedDescription
		)
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

	private var characterImage: some View {
		CachedAsyncImage(url: character.imageURL) { image in
			image
				.resizable()
				.scaledToFill()
		} placeholder: {
			ProgressView()
		}
		.frame(width: 70, height: 70)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
	}

	private var characterInfo: some View {
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

	private var statusIndicator: some View {
		VStack(spacing: SpacingToken.xs) {
			DSStatusIndicator(status: characterStatus)

			Text(character.status.rawValue)
				.font(TextStyle.caption.font)
				.foregroundStyle(ColorToken.textSecondary)
		}
	}

	private var characterStatus: DSStatus {
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

	func execute(page: Int) async throws -> CharactersPage {
		if delay {
			try? await Task.sleep(for: .seconds(100))
		}
		if shouldFail {
			throw PreviewError.failed
		}
		if isEmpty {
			return CharactersPage(
				characters: [],
				currentPage: 1,
				totalPages: 0,
				totalCount: 0,
				hasNextPage: false,
				hasPreviousPage: false
			)
		}
		return CharactersPage(
			characters: [
				Character(
					id: 1,
					name: "Rick Sanchez",
					status: .alive,
					species: "Human",
					gender: "Male",
					origin: Location(name: "Earth (C-137)", url: nil),
					location: Location(name: "Citadel of Ricks", url: nil),
					imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
				),
				Character(
					id: 2,
					name: "Morty Smith",
					status: .alive,
					species: "Human",
					gender: "Male",
					origin: Location(name: "Earth (C-137)", url: nil),
					location: Location(name: "Citadel of Ricks", url: nil),
					imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")
				),
				Character(
					id: 3,
					name: "Summer Smith",
					status: .alive,
					species: "Human",
					gender: "Female",
					origin: Location(name: "Earth (Replacement Dimension)", url: nil),
					location: Location(name: "Earth (Replacement Dimension)", url: nil),
					imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/3.jpeg")
				)
			],
			currentPage: 1,
			totalPages: 42,
			totalCount: 826,
			hasNextPage: true,
			hasPreviousPage: false
		)
	}
}

private enum PreviewError: Error {
	case failed
}

private final class RouterPreviewMock: RouterContract {
	func navigate(to destination: any Navigation) {}
	func goBack() {}
}
