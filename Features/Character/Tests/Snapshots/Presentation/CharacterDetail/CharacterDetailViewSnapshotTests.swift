import ChallengeCoreMocks
import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeCharacter

struct CharacterDetailViewSnapshotTests {
	private let imageLoader: ImageLoaderMock

	init() {
		UIView.setAnimationsEnabled(false)
		imageLoader = ImageLoaderMock(cachedImage: .stub, asyncImage: .stub)
	}

	// MARK: - Idle State

	@Test
	func idleState() {
		// Given
		let viewModel = CharacterDetailViewModelStub(state: .idle)

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Loading State

	@Test
	func loadingState() {
		// Given
		let viewModel = CharacterDetailViewModelStub(state: .loading)

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Loaded State

	@Test
	func loadedStateAliveCharacter() {
		// Given
		let character = Character.stub(
			name: "Rick Sanchez",
			status: .alive,
			species: "Human",
			gender: .male
		)
		let viewModel = CharacterDetailViewModelStub(state: .loaded(character))

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	@Test
	func loadedStateDeadCharacter() {
		// Given
		let character = Character.stub(
			name: "Birdperson",
			status: .dead,
			species: "Birdperson"
		)
		let viewModel = CharacterDetailViewModelStub(state: .loaded(character))

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	@Test
	func loadedStateUnknownStatus() {
		// Given
		let character = Character.stub(
			name: "Mystery Character",
			status: .unknown,
			species: "Unknown"
		)
		let viewModel = CharacterDetailViewModelStub(state: .loaded(character))

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	@Test
	func loadedStateWithImagePlaceholder() {
		// Given
		let character = Character.stub()
		let viewModel = CharacterDetailViewModelStub(state: .loaded(character))
		let imageLoaderWithoutImage = ImageLoaderMock(cachedImage: nil, asyncImage: nil)

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoaderWithoutImage)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Error State

	@Test
	func errorState() {
		// Given
		let viewModel = CharacterDetailViewModelStub(state: .error(.loadFailed))

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}
