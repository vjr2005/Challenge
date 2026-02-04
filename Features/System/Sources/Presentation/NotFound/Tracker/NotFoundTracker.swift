import ChallengeCore

struct NotFoundTracker: NotFoundTrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(NotFoundEvent.screenViewed)
    }

    func trackGoBackButtonTapped() {
        tracker.track(NotFoundEvent.goBackButtonTapped)
    }
}
