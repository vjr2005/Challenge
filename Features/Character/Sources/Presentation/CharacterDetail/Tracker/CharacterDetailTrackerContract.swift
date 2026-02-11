protocol CharacterDetailTrackerContract {
    func trackScreenViewed(identifier: Int)
    func trackRetryButtonTapped()
    func trackPullToRefreshTriggered()
    func trackEpisodesButtonTapped(identifier: Int)
    func trackLoadError(description: String)
    func trackRefreshError(description: String)
}
