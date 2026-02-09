import ChallengeCore

public final class EpisodeContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Init

    public init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    // MARK: - Factories

    func makeEpisodeListViewModel(navigator: any NavigatorContract) -> EpisodeListViewModel {
        EpisodeListViewModel(
            navigator: EpisodeListNavigator(navigator: navigator),
            tracker: EpisodeListTracker(tracker: tracker)
        )
    }
}
