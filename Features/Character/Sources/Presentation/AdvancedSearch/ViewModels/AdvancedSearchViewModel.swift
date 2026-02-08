import Foundation

@Observable
final class AdvancedSearchViewModel: AdvancedSearchViewModelContract {
    var filter: CharacterFilter

    var hasActiveFilters: Bool {
        filter.activeFilterCount > 0
    }

    private let delegate: any CharacterFilterDelegate
    private let navigator: AdvancedSearchNavigatorContract
    private let tracker: AdvancedSearchTrackerContract

    init(
        delegate: any CharacterFilterDelegate,
        navigator: AdvancedSearchNavigatorContract,
        tracker: AdvancedSearchTrackerContract
    ) {
        self.filter = delegate.currentFilter
        self.delegate = delegate
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }

    func didTapApply() {
        tracker.trackApplyFilters(filterCount: filter.activeFilterCount)
        delegate.didApplyFilter(filter)
        navigator.dismiss()
    }

    func didTapReset() {
        filter = .empty
        tracker.trackResetFilters()
    }

    func didTapClose() {
        tracker.trackCloseTapped()
        navigator.dismiss()
    }
}
