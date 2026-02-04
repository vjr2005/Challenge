import ChallengeCore

struct HomeTracker: HomeTrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(HomeEvent.screenViewed)
    }

    func trackCharacterButtonTapped() {
        tracker.track(HomeEvent.characterButtonTapped)
    }
}
