import ChallengeCore

struct CharacterListTracker: CharacterListTrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(CharacterListEvent.screenViewed)
    }

    func trackCharacterSelected(identifier: Int) {
        tracker.track(CharacterListEvent.characterSelected(identifier: identifier))
    }

    func trackSearchPerformed(query: String) {
        tracker.track(CharacterListEvent.searchPerformed(query: query))
    }

    func trackRetryButtonTapped() {
        tracker.track(CharacterListEvent.retryButtonTapped)
    }

    func trackPullToRefreshTriggered() {
        tracker.track(CharacterListEvent.pullToRefreshTriggered)
    }

    func trackLoadMoreButtonTapped() {
        tracker.track(CharacterListEvent.loadMoreButtonTapped)
    }
}
