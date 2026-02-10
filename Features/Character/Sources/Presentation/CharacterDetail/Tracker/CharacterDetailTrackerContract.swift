protocol CharacterDetailTrackerContract {
    func trackScreenViewed(identifier: Int)
    func trackRetryButtonTapped()
    func trackPullToRefreshTriggered()
    func trackBackButtonTapped()
    func trackEpisodesButtonTapped(identifier: Int)
    func trackLoadError(description: String)
    func trackRefreshError(description: String)
}
