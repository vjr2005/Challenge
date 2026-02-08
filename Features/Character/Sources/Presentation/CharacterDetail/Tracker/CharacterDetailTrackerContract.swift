protocol CharacterDetailTrackerContract {
    func trackScreenViewed(identifier: Int)
    func trackRetryButtonTapped()
    func trackPullToRefreshTriggered()
    func trackBackButtonTapped()
    func trackLoadError(description: String)
    func trackRefreshError(description: String)
}
