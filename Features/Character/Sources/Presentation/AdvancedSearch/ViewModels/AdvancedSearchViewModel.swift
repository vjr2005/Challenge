import Foundation

@Observable
final class AdvancedSearchViewModel: AdvancedSearchViewModelContract {
    let localFilterState = CharacterFilterState()

    var hasActiveFilters: Bool {
        !localFilterState.filter.isEmpty
    }

    private let filterState: CharacterFilterState
    private let navigator: AdvancedSearchNavigatorContract
    private let tracker: AdvancedSearchTrackerContract

    init(
        filterState: CharacterFilterState,
        navigator: AdvancedSearchNavigatorContract,
        tracker: AdvancedSearchTrackerContract
    ) {
        self.filterState = filterState
        self.navigator = navigator
        self.tracker = tracker
        localFilterState.apply(from: filterState)
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }

    func didTapApply() {
        filterState.apply(from: localFilterState)
        tracker.trackApplyFilters(filterCount: filterState.filter.activeFilterCount)
        navigator.dismiss()
    }

    func didTapReset() {
        localFilterState.reset()
        tracker.trackResetFilters()
    }

    func didTapClose() {
        tracker.trackCloseTapped()
        navigator.dismiss()
    }
}
