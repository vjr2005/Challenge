import Foundation

@testable import ChallengeHome

/// ViewModel stub for HomeView snapshot tests.
/// Provides no-op implementations for all actions.
final class HomeViewModelStub: HomeViewModelContract {
	func didAppear() {
		// No-op: tracking not tested in snapshots
	}

	func didTapOnCharacterButton() {
		// No-op: navigation not tested in snapshots
	}
}
