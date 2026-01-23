import ChallengeCoreMocks
import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeCharacter

struct CharacterDetailViewSnapshotTests {
	private let imageLoader: ImageLoaderMock

	init() {
		UIView.setAnimationsEnabled(false)
		imageLoader = ImageLoaderMock(image: SnapshotStubs.testImage)
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
			gender: "Male"
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

	// MARK: - Error State

	@Test
	func errorState() {
		// Given
		let viewModel = CharacterDetailViewModelStub(state: .error(SnapshotTestError.loadFailed))

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}

// MARK: - Test Helpers

private enum SnapshotTestError: LocalizedError {
	case loadFailed

	var errorDescription: String? {
		"Failed to load character details"
	}
}
