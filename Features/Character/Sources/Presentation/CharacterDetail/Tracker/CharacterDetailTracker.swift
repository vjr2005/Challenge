import ChallengeCore

struct CharacterDetailTracker: CharacterDetailTrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed(identifier: Int) {
        tracker.track(CharacterDetailEvent.screenViewed(identifier: identifier))
    }

    func trackRetryButtonTapped() {
        tracker.track(CharacterDetailEvent.retryButtonTapped)
    }

    func trackPullToRefreshTriggered() {
        tracker.track(CharacterDetailEvent.pullToRefreshTriggered)
    }

    func trackBackButtonTapped() {
        tracker.track(CharacterDetailEvent.backButtonTapped)
    }

    func trackEpisodesButtonTapped(identifier: Int) {
        tracker.track(CharacterDetailEvent.episodesButtonTapped(identifier: identifier))
    }

    func trackLoadError(description: String) {
        tracker.track(CharacterDetailEvent.loadError(description: description))
    }

    func trackRefreshError(description: String) {
        tracker.track(CharacterDetailEvent.refreshError(description: description))
    }
}
