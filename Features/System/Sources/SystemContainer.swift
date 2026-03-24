import ChallengeCore
import SwiftUI

/// Dependency container for the System feature.
struct SystemContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Init

    /// Creates a new system container.
    /// - Parameter tracker: The tracker used to register analytics events.
    init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    // MARK: - Factories

    func makeNotFoundView(navigator: any NavigatorContract) -> some View {
        NotFoundView(
            viewModel: NotFoundViewModel(
                navigator: NotFoundNavigator(navigator: navigator),
                tracker: NotFoundTracker(tracker: tracker)
            )
        )
    }
}
