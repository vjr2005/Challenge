import ChallengeCore

/// Dependency container for the Home feature.
public final class HomeContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Init

    /// Creates a new home container.
    /// - Parameter tracker: The tracker used to register analytics events.
    public init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    // MARK: - Factories

    func makeHomeViewModel(navigator: any NavigatorContract) -> HomeViewModel {
        HomeViewModel(navigator: HomeNavigator(navigator: navigator), tracker: HomeTracker(tracker: tracker))
    }

    func makeAboutViewModel(navigator: any NavigatorContract) -> AboutViewModel {
        AboutViewModel(
            getAboutInfoUseCase: GetAboutInfoUseCase(),
            navigator: AboutNavigator(navigator: navigator),
            tracker: AboutTracker(tracker: tracker)
        )
    }
}
