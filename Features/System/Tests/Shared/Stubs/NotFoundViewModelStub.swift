import Foundation

@testable import ChallengeSystem

/// ViewModel stub for NotFoundView snapshot tests.
/// Provides no-op implementations for all actions.
final class NotFoundViewModelStub: NotFoundViewModelContract {
    func didAppear() {
        // No-op: tracking not tested in snapshots
    }

    func didTapGoBack() {
        // No-op: navigation not tested in snapshots
    }
}
