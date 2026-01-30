import Foundation

@testable import ChallengeHome

/// ViewModel stub for HomeView snapshot tests.
/// Provides no-op implementations for all actions.
final class HomeViewModelStub: HomeViewModelContract {
	func didTapOnCharacterButton() {
		// No-op: navigation not tested in snapshots
	}
}
