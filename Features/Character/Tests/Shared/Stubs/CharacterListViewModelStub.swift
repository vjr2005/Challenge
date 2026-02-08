import Foundation

@testable import ChallengeCharacter

/// ViewModel stub for CharacterListView snapshot tests.
/// Maintains a fixed state without performing any async operations.
@Observable
final class CharacterListViewModelStub: CharacterListViewModelContract {
	var state: CharacterListViewState
	var searchQuery: String = ""
	var recentSearches: [String] = []
	var activeFilterCount: Int = 0

	init(state: CharacterListViewState) {
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

	func didTapOnLoadMoreButton() async {
		// No-op: state is fixed for snapshots
	}

	func didSelect(_ character: Character) {
		// No-op: navigation not tested in snapshots
	}

	func didSelectRecentSearch(_ query: String) async {
		// No-op: recent searches not tested in snapshots
	}

	func didDeleteRecentSearch(_ query: String) {
		// No-op: recent searches not tested in snapshots
	}

	func didTapAdvancedSearchButton() {
		// No-op: navigation not tested in snapshots
	}
}
