protocol CharacterDetailTrackerContract {
    func trackScreenViewed(identifier: Int)
    func trackRetryButtonTapped()
    func trackPullToRefreshTriggered()
    func trackBackButtonTapped()
}
