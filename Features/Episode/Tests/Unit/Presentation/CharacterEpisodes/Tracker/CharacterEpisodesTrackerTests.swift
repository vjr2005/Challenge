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

    // MARK: - Tests

    @Test("Track screen viewed dispatches correct event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_episodes_viewed", properties: ["character_id": "42"])

        // When
        sut.trackScreenViewed(characterIdentifier: 42)

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track retry button tapped dispatches correct event")
    func trackRetryButtonTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_episodes_retry_tapped", properties: [:])

        // When
        sut.trackRetryButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track pull to refresh triggered dispatches correct event")
    func trackPullToRefreshTriggeredDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_episodes_pull_to_refresh", properties: [:])

        // When
        sut.trackPullToRefreshTriggered()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track character avatar tapped dispatches correct event")
    func trackCharacterAvatarTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_episodes_character_avatar_tapped", properties: ["character_id": "42"])

        // When
        sut.trackCharacterAvatarTapped(identifier: 42)

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track load error dispatches correct event")
    func trackLoadErrorDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_episodes_load_error", properties: ["description": "network error"])

        // When
        sut.trackLoadError(description: "network error")

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track refresh error dispatches correct event")
    func trackRefreshErrorDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_episodes_refresh_error", properties: ["description": "timeout"])

        // When
        sut.trackRefreshError(description: "timeout")

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }
}
