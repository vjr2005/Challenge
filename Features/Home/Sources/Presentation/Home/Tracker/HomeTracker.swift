import ChallengeCore

struct HomeTracker: HomeTrackerContract {
    private let tracker: any TrackerContract

    init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(HomeEvent.screenViewed)
    }

    func trackCharacterButtonTapped() {
        tracker.track(HomeEvent.characterButtonTapped)
    }

    func trackInfoButtonTapped() {
        tracker.track(HomeEvent.infoButtonTapped)
    }
}
