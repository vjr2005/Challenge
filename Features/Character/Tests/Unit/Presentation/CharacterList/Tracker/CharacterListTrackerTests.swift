import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterListTrackerTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let sut: CharacterListTracker

    // MARK: - Initialization

    init() {
        sut = CharacterListTracker(tracker: trackerMock)
    }

    // MARK: - Tests

    @Test("Track screen viewed dispatches character list viewed event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_list_viewed", properties: [:])

        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track character selected dispatches event with identifier")
    func trackCharacterSelectedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_selected", properties: ["id": "42"])

        // When
        sut.trackCharacterSelected(identifier: 42)

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track search performed dispatches event with query")
    func trackSearchPerformedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "search_performed", properties: ["query": "Rick"])

        // When
        sut.trackSearchPerformed(query: "Rick")

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track retry button tapped dispatches correct event")
    func trackRetryButtonTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_list_retry_tapped", properties: [:])

        // When
        sut.trackRetryButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track pull to refresh triggered dispatches correct event")
    func trackPullToRefreshTriggeredDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_list_pull_to_refresh", properties: [:])

        // When
        sut.trackPullToRefreshTriggered()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track load more button tapped dispatches correct event")
    func trackLoadMoreButtonTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_list_load_more_tapped", properties: [:])

        // When
        sut.trackLoadMoreButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track character filter button tapped dispatches correct event")
    func trackCharacterFilterButtonTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_list_character_filter_tapped", properties: [:])

        // When
        sut.trackCharacterFilterButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track fetch error dispatches event with description")
    func trackFetchErrorDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_list_fetch_error", properties: ["description": "Load failed"])

        // When
        sut.trackFetchError(description: "Load failed")

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track refresh error dispatches event with description")
    func trackRefreshErrorDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_list_refresh_error", properties: ["description": "Refresh failed"])

        // When
        sut.trackRefreshError(description: "Refresh failed")

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track load more error dispatches event with description")
    func trackLoadMoreErrorDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_list_load_more_error", properties: ["description": "Load more failed"])

        // When
        sut.trackLoadMoreError(description: "Load more failed")

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }
}
