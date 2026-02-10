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
        // When
        sut.trackScreenViewed(identifier: 42)

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_detail_viewed", properties: ["id": "42"]))
    }

    @Test("Track retry button tapped dispatches correct event")
    func trackRetryButtonTappedDispatchesCorrectEvent() {
        // When
        sut.trackRetryButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_detail_retry_tapped", properties: [:]))
    }

    @Test("Track pull to refresh triggered dispatches correct event")
    func trackPullToRefreshTriggeredDispatchesCorrectEvent() {
        // When
        sut.trackPullToRefreshTriggered()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_detail_pull_to_refresh", properties: [:]))
    }

    @Test("Track back button tapped dispatches correct event")
    func trackBackButtonTappedDispatchesCorrectEvent() {
        // When
        sut.trackBackButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_detail_back_tapped", properties: [:]))
    }

    @Test("Track episodes button tapped dispatches correct event with identifier")
    func trackEpisodesButtonTappedDispatchesCorrectEvent() {
        // When
        sut.trackEpisodesButtonTapped(identifier: 42)

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_detail_episodes_tapped", properties: ["id": "42"]))
    }

    @Test("Track load error dispatches event with description")
    func trackLoadErrorDispatchesCorrectEvent() {
        // When
        sut.trackLoadError(description: "Load failed")

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_detail_load_error", properties: ["description": "Load failed"]))
    }

    @Test("Track refresh error dispatches event with description")
    func trackRefreshErrorDispatchesCorrectEvent() {
        // When
        sut.trackRefreshError(description: "Refresh failed")

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_detail_refresh_error", properties: ["description": "Refresh failed"]))
    }
}
