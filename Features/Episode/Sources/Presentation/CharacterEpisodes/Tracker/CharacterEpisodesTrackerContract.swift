protocol CharacterEpisodesTrackerContract {
	func trackScreenViewed(characterIdentifier: Int)
	func trackRetryButtonTapped()
	func trackPullToRefreshTriggered()
	func trackCharacterAvatarTapped(identifier: Int)
	func trackLoadError(description: String)
	func trackRefreshError(description: String)
}
