protocol CharacterFilterTrackerContract {
    func trackScreenViewed()
    func trackApplyFilters(filterCount: Int)
    func trackResetFilters()
    func trackCloseTapped()
}
