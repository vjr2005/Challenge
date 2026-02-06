protocol AdvancedSearchViewModelContract: AnyObject {
    var localFilterState: CharacterFilterState { get }
    var hasActiveFilters: Bool { get }
    func didAppear()
    func didTapApply()
    func didTapReset()
    func didTapClose()
}
