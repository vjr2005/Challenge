import ChallengeCoreMocks
import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeCharacter

struct CharacterListViewSnapshotTests {
	private let imageLoader: ImageLoaderMock

	init() {
		UIView.setAnimationsEnabled(false)
		imageLoader = ImageLoaderMock(cachedImage: .stub, asyncImage: .stub)
	}

	// MARK: - Idle State

	@Test("Renders character list view in idle state")
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

	@Test("Renders character list view in loading state")
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

	@Test("Renders character list with multiple characters in different statuses")
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

	@Test("Renders character list without pagination indicator when no next page")
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

	@Test("Renders character list with image placeholder when image not available")
	func loadedStateWithImagePlaceholder() {
		// Given
		let page = CharactersPage.stub(characters: [.stub()])
		let viewModel = CharacterListViewModelStub(state: .loaded(page))
		let imageLoaderWithoutImage = ImageLoaderMock(cachedImage: nil, asyncImage: nil)

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoaderWithoutImage)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Empty State

	@Test("Renders character list empty state when no characters returned")
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

	// MARK: - Empty Search State

	@Test("Renders character list empty search state when search has no results")
	func emptySearchState() {
		// Given
		let viewModel = CharacterListViewModelStub(state: .emptySearch)

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Error State

	@Test("Renders character list error state with retry option")
	func errorState() {
		// Given
		let viewModel = CharacterListViewModelStub(state: .error(.loadFailed()))

		// When
		let view = NavigationStack {
			CharacterListView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}
