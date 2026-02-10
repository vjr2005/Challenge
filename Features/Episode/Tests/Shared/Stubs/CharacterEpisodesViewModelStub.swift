import Foundation

@testable import ChallengeEpisode

/// ViewModel stub for CharacterEpisodesView snapshot tests.
/// Maintains a fixed state without performing any async operations.
@Observable
final class CharacterEpisodesViewModelStub: CharacterEpisodesViewModelContract {
	var state: CharacterEpisodesViewState

	init(state: CharacterEpisodesViewState = .idle) {
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

	func didTapOnCharacter(identifier: Int) {
		// No-op: state is fixed for snapshots
	}
}
