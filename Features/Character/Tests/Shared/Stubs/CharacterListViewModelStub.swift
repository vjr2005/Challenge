import Foundation

@testable import ChallengeCharacter

/// ViewModel stub for CharacterListView snapshot tests.
/// Maintains a fixed state without performing any async operations.
@Observable
final class CharacterListViewModelStub: CharacterListViewModelContract {
	var state: CharacterListViewState
	var searchQuery: String = ""

	init(state: CharacterListViewState) {
		self.state = state
	}

	func loadIfNeeded() async {
		// No-op: state is fixed for snapshots
	}

	func refresh() async {
		// No-op: state is fixed for snapshots
	}

	func loadMore() async {
		// No-op: state is fixed for snapshots
	}

	func didSelect(_ character: Character) {
		// No-op: navigation not tested in snapshots
	}
}
