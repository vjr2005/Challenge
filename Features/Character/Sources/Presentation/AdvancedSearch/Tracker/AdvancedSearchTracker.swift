import ChallengeCore

struct AdvancedSearchTracker: AdvancedSearchTrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track(AdvancedSearchEvent.screenViewed)
    }

    func trackApplyFilters(filterCount: Int) {
        tracker.track(AdvancedSearchEvent.filtersApplied(filterCount: filterCount))
    }

    func trackResetFilters() {
        tracker.track(AdvancedSearchEvent.filtersReset)
    }

    func trackCloseTapped() {
        tracker.track(AdvancedSearchEvent.closeTapped)
    }
}
