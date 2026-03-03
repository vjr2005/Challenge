import ChallengeCore

struct NotFoundTracker: NotFoundTrackerContract {
    private let tracker: any TrackerContract

    init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(NotFoundEvent.screenViewed)
    }

    func trackGoBackButtonTapped() {
        tracker.track(NotFoundEvent.goBackButtonTapped)
    }
}
