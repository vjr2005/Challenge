protocol CharacterEpisodesTrackerContract {
	func trackScreenViewed(characterIdentifier: Int)
	func trackRetryButtonTapped()
	func trackPullToRefreshTriggered()
	func trackLoadError(description: String)
	func trackRefreshError(description: String)
}
