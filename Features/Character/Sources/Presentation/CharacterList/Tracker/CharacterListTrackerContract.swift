protocol CharacterListTrackerContract {
    func trackScreenViewed()
    func trackCharacterSelected(identifier: Int)
    func trackSearchPerformed(query: String)
    func trackRetryButtonTapped()
    func trackPullToRefreshTriggered()
    func trackLoadMoreButtonTapped()
    func trackAdvancedSearchButtonTapped()
    func trackFetchError(description: String)
    func trackRefreshError(description: String)
    func trackLoadMoreError(description: String)
}
