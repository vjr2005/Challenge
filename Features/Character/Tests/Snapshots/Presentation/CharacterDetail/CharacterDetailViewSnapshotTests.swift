import ChallengeCoreMocks
import ChallengeSnapshotTestKit
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

	@Test("Renders character detail view in idle state")
	func idleState() {
		// Given
		let viewModel = CharacterDetailViewModelStub(state: .idle)

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .device)
	}

	// MARK: - Loading State

	@Test("Renders character detail view in loading state")
	func loadingState() {
		// Given
		let viewModel = CharacterDetailViewModelStub(state: .loading)

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .device)
	}

	// MARK: - Loaded State

	@Test("Renders character detail with alive status indicator")
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
		assertSnapshot(of: view, as: .device)
	}

	@Test("Renders character detail with dead status indicator")
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
		assertSnapshot(of: view, as: .device)
	}

	@Test("Renders character detail with unknown status indicator")
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
		assertSnapshot(of: view, as: .device)
	}

	@Test("Renders character detail with image placeholder when image not available")
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
		assertSnapshot(of: view, as: .device)
	}

	// MARK: - Error State

	@Test("Renders character detail error state with retry option")
	func errorState() {
		// Given
		let viewModel = CharacterDetailViewModelStub(state: .error(.loadFailed()))

		// When
		let view = NavigationStack {
			CharacterDetailView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .device)
	}
}
