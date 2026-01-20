import ChallengeCommon
import ChallengeCore
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
		VStack(spacing: 16) {
			ProgressView()
				.scaleEffect(1.5)
			Text(LocalizedStrings.loading)
				.font(.subheadline)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	func characterList(page: CharactersPage) -> some View {
		ScrollView {
			LazyVStack(spacing: 16) {
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
			.padding(.horizontal)
		}
		.accessibilityIdentifier(AccessibilityIdentifier.scrollView)
		.background(Color(.systemGroupedBackground))
	}

	func headerView(totalCount: Int) -> some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(LocalizedStrings.headerTitle)
				.font(.system(.largeTitle, design: .rounded, weight: .bold))
				.foregroundStyle(.primary)

			Text(LocalizedStrings.headerSubtitle(totalCount))
				.font(.system(.subheadline, design: .serif))
				.foregroundStyle(.secondary)
				.italic()
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.vertical, 8)
	}

	var loadMoreButton: some View {
		Button {
			Task {
				await viewModel.loadMore()
			}
		} label: {
			HStack(spacing: 8) {
				Text(LocalizedStrings.loadMore)
					.font(.system(.body, design: .rounded, weight: .semibold))
				Image(systemName: "arrow.down.circle.fill")
			}
			.frame(maxWidth: .infinity)
			.padding(.vertical, 12)
			.background(Color.accentColor.opacity(0.1))
			.foregroundStyle(Color.accentColor)
			.clipShape(RoundedRectangle(cornerRadius: 12))
		}
		.accessibilityIdentifier(AccessibilityIdentifier.loadMoreButton)
		.padding(.vertical, 8)
	}

	func footerView(page: CharactersPage) -> some View {
		Text(LocalizedStrings.pageIndicator(page.currentPage, page.totalPages))
			.font(.system(.caption, design: .monospaced))
			.foregroundStyle(.tertiary)
			.padding(.bottom, 16)
	}

	var emptyView: some View {
		ContentUnavailableView {
			Label {
				Text(LocalizedStrings.Empty.title)
			} icon: {
				Image(systemName: "person.slash")
			}
		} description: {
			Text(LocalizedStrings.Empty.description)
		}
	}

	func errorView(error: Error) -> some View {
		ContentUnavailableView {
			Label {
				Text(LocalizedStrings.Error.title)
			} icon: {
				Image(systemName: "exclamationmark.triangle")
			}
		} description: {
			Text(error.localizedDescription)
		}
	}
}

// MARK: - Character Row

private struct CharacterRowView: View {
	let character: Character

	var body: some View {
		HStack(spacing: 16) {
			characterImage
			characterInfo
			Spacer()
			statusIndicator
		}
		.padding(16)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
		.clipShape(RoundedRectangle(cornerRadius: 12))
	}

	private var characterInfo: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(character.name)
				.font(.system(.headline, design: .rounded, weight: .semibold))
				.foregroundStyle(.primary)
				.lineLimit(1)

			Text(character.species)
				.font(.system(.subheadline, design: .serif))
				.foregroundStyle(.secondary)

			HStack(spacing: 4) {
				Image(systemName: "mappin.circle.fill")
					.font(.caption2)
				Text(character.location.name)
					.font(.system(.caption, design: .monospaced))
			}
			.foregroundStyle(.tertiary)
			.lineLimit(1)
		}
	}

	private var statusIndicator: some View {
		VStack(spacing: 4) {
			Circle()
				.fill(statusColor)
				.frame(width: 12, height: 12)

			Text(character.status.rawValue)
				.font(.system(.caption2, design: .rounded, weight: .medium))
				.foregroundStyle(.secondary)
		}
	}

	private var statusColor: Color {
		switch character.status {
		case .alive:
			.green
		case .dead:
			.red
		case .unknown:
			.gray
		}
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
