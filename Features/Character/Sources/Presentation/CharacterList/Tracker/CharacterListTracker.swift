import ChallengeCore

struct CharacterListTracker: CharacterListTrackerContract {
    private let tracker: any TrackerContract

    init(tracker: any TrackerContract) {
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

    func trackCharacterFilterButtonTapped() {
        tracker.track(CharacterListEvent.characterFilterButtonTapped)
    }

    func trackFetchError(description: String) {
        tracker.track(CharacterListEvent.fetchError(description: description))
    }

    func trackRefreshError(description: String) {
        tracker.track(CharacterListEvent.refreshError(description: description))
    }

    func trackLoadMoreError(description: String) {
        tracker.track(CharacterListEvent.loadMoreError(description: description))
    }
}
