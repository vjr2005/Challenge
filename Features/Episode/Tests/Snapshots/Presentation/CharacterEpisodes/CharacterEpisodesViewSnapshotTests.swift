import ChallengeCoreMocks
import ChallengeSnapshotTestKit
import SwiftUI
import Testing

@testable import ChallengeEpisode

struct CharacterEpisodesViewSnapshotTests {
	private let imageLoader: ImageLoaderMock

	init() {
		UIView.setAnimationsEnabled(false)
		imageLoader = ImageLoaderMock(cachedImage: .stub, asyncImage: .stub)
	}

	// MARK: - Idle State

	@Test("Renders character episodes view in idle state")
	func idleState() {
		// Given
		let viewModel = CharacterEpisodesViewModelStub(state: .idle)

		// When
		let view = NavigationStack {
			CharacterEpisodesView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .device)
	}

	// MARK: - Loading State

	@Test("Renders character episodes view in loading state")
	func loadingState() {
		// Given
		let viewModel = CharacterEpisodesViewModelStub(state: .loading)

		// When
		let view = NavigationStack {
			CharacterEpisodesView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .device)
	}

	// MARK: - Loaded State

	@Test("Renders character episodes view with episodes and characters")
	func loadedState() {
		// Given
		let viewModel = CharacterEpisodesViewModelStub(state: .loaded(.stub()))

		// When
		let view = NavigationStack {
			CharacterEpisodesView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .device)
	}

	@Test("Renders character episodes view with image placeholders when images not available")
	func loadedStateWithImagePlaceholder() {
		// Given
		let data = EpisodeCharacterWithEpisodes.stub(imageURL: nil)
		let viewModel = CharacterEpisodesViewModelStub(state: .loaded(data))
		let imageLoaderWithoutImage = ImageLoaderMock(cachedImage: nil, asyncImage: nil)

		// When
		let view = NavigationStack {
			CharacterEpisodesView(viewModel: viewModel)
		}
		.imageLoader(imageLoaderWithoutImage)

		// Then
		assertSnapshot(of: view, as: .device)
	}

	// MARK: - Error State

	@Test("Renders character episodes error state with retry option")
	func errorState() {
		// Given
		let viewModel = CharacterEpisodesViewModelStub(state: .error(.loadFailed()))

		// When
		let view = NavigationStack {
			CharacterEpisodesView(viewModel: viewModel)
		}
		.imageLoader(imageLoader)

		// Then
		assertSnapshot(of: view, as: .device)
	}
}
