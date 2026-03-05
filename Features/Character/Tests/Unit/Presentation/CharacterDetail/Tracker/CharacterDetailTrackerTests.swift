import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterDetailTrackerTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let sut: CharacterDetailTracker

    // MARK: - Initialization

    init() {
        sut = CharacterDetailTracker(tracker: trackerMock)
    }

    // MARK: - Tests

    @Test("Track screen viewed dispatches character detail viewed event with identifier")
    func trackScreenViewedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_detail_viewed", properties: ["id": "42"])

        // When
        sut.trackScreenViewed(identifier: 42)

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track retry button tapped dispatches correct event")
    func trackRetryButtonTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_detail_retry_tapped", properties: [:])

        // When
        sut.trackRetryButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track pull to refresh triggered dispatches correct event")
    func trackPullToRefreshTriggeredDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_detail_pull_to_refresh", properties: [:])

        // When
        sut.trackPullToRefreshTriggered()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track episodes button tapped dispatches correct event with identifier")
    func trackEpisodesButtonTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_detail_episodes_tapped", properties: ["id": "42"])

        // When
        sut.trackEpisodesButtonTapped(identifier: 42)

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track load error dispatches event with description")
    func trackLoadErrorDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_detail_load_error", properties: ["description": "Load failed"])

        // When
        sut.trackLoadError(description: "Load failed")

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track refresh error dispatches event with description")
    func trackRefreshErrorDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_detail_refresh_error", properties: ["description": "Refresh failed"])

        // When
        sut.trackRefreshError(description: "Refresh failed")

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }
}
