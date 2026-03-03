import ChallengeCore

struct CharacterFilterTracker: CharacterFilterTrackerContract {
    private let tracker: any TrackerContract

    init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(CharacterFilterEvent.screenViewed)
    }

    func trackApplyFilters(filterCount: Int) {
        tracker.track(CharacterFilterEvent.filtersApplied(filterCount: filterCount))
    }

    func trackResetFilters() {
        tracker.track(CharacterFilterEvent.filtersReset)
    }

    func trackCloseTapped() {
        tracker.track(CharacterFilterEvent.closeTapped)
    }
}
