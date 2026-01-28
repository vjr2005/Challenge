import ChallengeCoreMocks
import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterListViewSnapshotTests {
	private let imageLoader: ImageLoaderMock

	init() {
		UIView.setAnimationsEnabled(false)
		imageLoader = ImageLoaderMock(image: .stub)
	}

	// MARK: - Idle State

	@Test
	func idleState() {
		// Given
		let viewModel = CharacterListViewModelStub(state: .idle)

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Loading State

	@Test
	func loadingState() {
		// Given
		let viewModel = CharacterListViewModelStub(state: .loading)

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Loaded State

	@Test
	func loadedStateWithCharacters() {
		// Given
		let page = CharactersPage.stub(
			characters: [
				.stub(id: 1, name: "Rick Sanchez", status: .alive),
				.stub(id: 2, name: "Morty Smith", status: .alive),
				.stub(id: 3, name: "Summer Smith", status: .dead)
			]
		)
		let viewModel = CharacterListViewModelStub(state: .loaded(page))

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	@Test
	func loadedStateWithoutNextPage() {
		// Given
		let page = CharactersPage.stub(
			characters: [.stub()],
			hasNextPage: false
		)
		let viewModel = CharacterListViewModelStub(state: .loaded(page))

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	@Test
	func loadedStateWithImagePlaceholder() {
		// Given
		let page = CharactersPage.stub(characters: [.stub()])
		let viewModel = CharacterListViewModelStub(state: .loaded(page))
		let imageLoaderWithoutImage = ImageLoaderMock(image: nil)

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoaderWithoutImage)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Empty State

	@Test
	func emptyState() {
		// Given
		let viewModel = CharacterListViewModelStub(state: .empty)

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Error State

	@Test
	func errorState() {
		// Given
		let viewModel = CharacterListViewModelStub(state: .error(SnapshotTestError.networkError))

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}

// MARK: - Test Helpers

private enum SnapshotTestError: LocalizedError {
	case networkError

	var errorDescription: String? {
		"Unable to connect to the server"
	}
}
