import Foundation

@Observable
final class CharacterFilterViewModel: CharacterFilterViewModelContract {
    var filter: CharacterFilter

    var hasActiveFilters: Bool {
        filter.activeFilterCount > 0
    }

    private let delegate: any CharacterFilterDelegate
    private let navigator: any CharacterFilterNavigatorContract
    private let tracker: any CharacterFilterTrackerContract

    init(
        delegate: any CharacterFilterDelegate,
        navigator: any CharacterFilterNavigatorContract,
        tracker: any CharacterFilterTrackerContract
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
