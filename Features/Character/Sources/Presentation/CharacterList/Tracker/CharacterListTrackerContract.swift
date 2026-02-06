protocol CharacterListTrackerContract {
    func trackScreenViewed()
    func trackCharacterSelected(identifier: Int)
    func trackSearchPerformed(query: String)
    func trackRetryButtonTapped()
    func trackPullToRefreshTriggered()
    func trackLoadMoreButtonTapped()
    func trackAdvancedSearchButtonTapped()
}
