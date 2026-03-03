import ChallengeCore

struct AboutTracker: AboutTrackerContract {
    private let tracker: any TrackerContract

    init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(AboutEvent.screenViewed)
    }
}
