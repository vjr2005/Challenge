final class EpisodeListViewModel: EpisodeListViewModelContract {
    // MARK: - Dependencies

    private let navigator: EpisodeListNavigatorContract
    private let tracker: EpisodeListTrackerContract

    // MARK: - Init

    init(
        navigator: EpisodeListNavigatorContract,
        tracker: EpisodeListTrackerContract
    ) {
        self.navigator = navigator
        self.tracker = tracker
    }

    // MARK: - EpisodeListViewModelContract

    func didAppear() {
        tracker.trackScreenViewed()
    }
}
