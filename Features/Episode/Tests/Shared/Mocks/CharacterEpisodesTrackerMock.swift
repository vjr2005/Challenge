@testable import ChallengeEpisode

final class CharacterEpisodesTrackerMock: CharacterEpisodesTrackerContract {
	private(set) var screenViewedCharacterIdentifiers: [Int] = []
	private(set) var retryButtonTappedCallCount = 0
	private(set) var pullToRefreshTriggeredCallCount = 0
	private(set) var characterAvatarTappedIdentifiers: [Int] = []
	private(set) var loadErrorDescriptions: [String] = []
	private(set) var refreshErrorDescriptions: [String] = []

	func trackScreenViewed(characterIdentifier: Int) {
		screenViewedCharacterIdentifiers.append(characterIdentifier)
	}

	func trackRetryButtonTapped() {
		retryButtonTappedCallCount += 1
	}

	func trackPullToRefreshTriggered() {
		pullToRefreshTriggeredCallCount += 1
	}

	func trackCharacterAvatarTapped(identifier: Int) {
		characterAvatarTappedIdentifiers.append(identifier)
	}

	func trackLoadError(description: String) {
		loadErrorDescriptions.append(description)
	}

	func trackRefreshError(description: String) {
		refreshErrorDescriptions.append(description)
	}
}
