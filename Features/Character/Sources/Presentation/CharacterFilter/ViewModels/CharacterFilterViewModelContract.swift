protocol CharacterFilterViewModelContract: AnyObject {
    var filter: CharacterFilter { get set }
    var hasActiveFilters: Bool { get }
    func didAppear()
    func didTapApply()
    func didTapReset()
    func didTapClose()
}
