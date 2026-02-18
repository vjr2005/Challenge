import Foundation

@testable import ChallengeCharacter

/// ViewModel stub for CharacterDetailView snapshot tests.
/// Maintains a fixed state without performing any async operations.
@Observable
final class CharacterDetailViewModelStub: CharacterDetailViewModelContract {
	var state: CharacterDetailViewState
	var imageRefreshID = UUID()

	init(state: CharacterDetailViewState) {
		self.state = state
	}

	func didAppear() async {
		// No-op: state is fixed for snapshots
	}

	func didTapOnRetryButton() async {
		// No-op: state is fixed for snapshots
	}

	func didPullToRefresh() async {
		// No-op: state is fixed for snapshots
	}

	func didTapOnEpisodes() {
		// No-op: navigation not tested in snapshots
	}
}
