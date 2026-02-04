import ChallengeCore

/// Dependency container for the System feature.
public final class SystemContainer: Sendable {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Init

    /// Creates a new system container.
    /// - Parameter tracker: The tracker used to register analytics events.
    public init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    // MARK: - Factories

    func makeNotFoundViewModel(navigator: any NavigatorContract) -> NotFoundViewModel {
        NotFoundViewModel(navigator: NotFoundNavigator(navigator: navigator), tracker: NotFoundTracker(tracker: tracker))
    }
}
