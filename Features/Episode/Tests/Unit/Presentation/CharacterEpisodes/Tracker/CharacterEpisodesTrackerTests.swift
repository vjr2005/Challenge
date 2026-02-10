import ChallengeCoreMocks
import Testing

@testable import ChallengeEpisode

struct CharacterEpisodesTrackerTests {
	// MARK: - Properties

	private let trackerMock = TrackerMock()
	private let sut: CharacterEpisodesTracker

	// MARK: - Init

	init() {
		sut = CharacterEpisodesTracker(tracker: trackerMock)
	}

	// MARK: - Track Screen Viewed

	@Test("Track screen viewed dispatches correct event")
	func trackScreenViewedDispatchesCorrectEvent() {
		// When
		sut.trackScreenViewed(characterIdentifier: 42)

		// Then
		#expect(trackerMock.trackedEvents.count == 1)
		#expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_episodes_viewed", properties: ["character_id": "42"]))
	}

	// MARK: - Track Retry Button Tapped

	@Test("Track retry button tapped dispatches correct event")
	func trackRetryButtonTappedDispatchesCorrectEvent() {
		// When
		sut.trackRetryButtonTapped()

		// Then
		#expect(trackerMock.trackedEvents.count == 1)
		#expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_episodes_retry_tapped", properties: [:]))
	}

	// MARK: - Track Pull To Refresh Triggered

	@Test("Track pull to refresh triggered dispatches correct event")
	func trackPullToRefreshTriggeredDispatchesCorrectEvent() {
		// When
		sut.trackPullToRefreshTriggered()

		// Then
		#expect(trackerMock.trackedEvents.count == 1)
		#expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_episodes_pull_to_refresh", properties: [:]))
	}

	// MARK: - Track Load Error

	@Test("Track load error dispatches correct event")
	func trackLoadErrorDispatchesCorrectEvent() {
		// When
		sut.trackLoadError(description: "network error")

		// Then
		#expect(trackerMock.trackedEvents.count == 1)
		#expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_episodes_load_error", properties: ["description": "network error"]))
	}

	// MARK: - Track Refresh Error

	@Test("Track refresh error dispatches correct event")
	func trackRefreshErrorDispatchesCorrectEvent() {
		// When
		sut.trackRefreshError(description: "timeout")

		// Then
		#expect(trackerMock.trackedEvents.count == 1)
		#expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_episodes_refresh_error", properties: ["description": "timeout"]))
	}
}
