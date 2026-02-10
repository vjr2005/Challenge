import ChallengeCore

struct CharacterEpisodesTracker: CharacterEpisodesTrackerContract {
	private let tracker: TrackerContract

	init(tracker: TrackerContract) {
		self.tracker = tracker
	}

	func trackScreenViewed(characterIdentifier: Int) {
		tracker.track(CharacterEpisodesEvent.screenViewed(characterIdentifier: characterIdentifier))
	}

	func trackRetryButtonTapped() {
		tracker.track(CharacterEpisodesEvent.retryButtonTapped)
	}

	func trackPullToRefreshTriggered() {
		tracker.track(CharacterEpisodesEvent.pullToRefreshTriggered)
	}

	func trackCharacterAvatarTapped(identifier: Int) {
		tracker.track(CharacterEpisodesEvent.characterAvatarTapped(identifier: identifier))
	}

	func trackLoadError(description: String) {
		tracker.track(CharacterEpisodesEvent.loadError(description: description))
	}

	func trackRefreshError(description: String) {
		tracker.track(CharacterEpisodesEvent.refreshError(description: description))
	}
}
