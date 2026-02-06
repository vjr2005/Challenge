import ChallengeCore

struct AboutTracker: AboutTrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(AboutEvent.screenViewed)
    }
}
