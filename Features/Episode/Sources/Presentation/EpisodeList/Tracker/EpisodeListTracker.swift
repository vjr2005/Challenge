import ChallengeCore

struct EpisodeListTracker: EpisodeListTrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(EpisodeListEvent.screenViewed)
    }
}
