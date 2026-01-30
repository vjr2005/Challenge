import Foundation

@testable import ChallengeCharacter

/// ViewModel stub for CharacterDetailView snapshot tests.
/// Maintains a fixed state without performing any async operations.
@Observable
final class CharacterDetailViewModelStub: CharacterDetailViewModelContract {
	var state: CharacterDetailViewState

	init(state: CharacterDetailViewState) {
		self.state = state
	}

	func load() async {
		// No-op: state is fixed for snapshots
	}

	func refresh() async {
		// No-op: state is fixed for snapshots
	}

	func didTapOnBack() {
		// No-op: navigation not tested in snapshots
	}
}
