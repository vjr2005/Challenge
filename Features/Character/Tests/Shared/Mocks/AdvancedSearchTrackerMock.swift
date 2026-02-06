@testable import ChallengeCharacter

final class AdvancedSearchTrackerMock: AdvancedSearchTrackerContract {
    private(set) var screenViewedCallCount = 0
    private(set) var applyFiltersCallCount = 0
    private(set) var lastAppliedFilterCount: Int?
    private(set) var resetFiltersCallCount = 0
    private(set) var closeTappedCallCount = 0

    func trackScreenViewed() {
        screenViewedCallCount += 1
    }

    func trackApplyFilters(filterCount: Int) {
        applyFiltersCallCount += 1
        lastAppliedFilterCount = filterCount
    }

    func trackResetFilters() {
        resetFiltersCallCount += 1
    }

    func trackCloseTapped() {
        closeTappedCallCount += 1
    }
}
