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
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_list_viewed", properties: [:]))
    }

    @Test("Track character selected dispatches event with identifier")
    func trackCharacterSelectedDispatchesCorrectEvent() {
        // When
        sut.trackCharacterSelected(identifier: 42)

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_selected", properties: ["id": "42"]))
    }

    @Test("Track search performed dispatches event with query")
    func trackSearchPerformedDispatchesCorrectEvent() {
        // When
        sut.trackSearchPerformed(query: "Rick")

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "search_performed", properties: ["query": "Rick"]))
    }

    @Test("Track retry button tapped dispatches correct event")
    func trackRetryButtonTappedDispatchesCorrectEvent() {
        // When
        sut.trackRetryButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_list_retry_tapped", properties: [:]))
    }

    @Test("Track pull to refresh triggered dispatches correct event")
    func trackPullToRefreshTriggeredDispatchesCorrectEvent() {
        // When
        sut.trackPullToRefreshTriggered()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_list_pull_to_refresh", properties: [:]))
    }

    @Test("Track load more button tapped dispatches correct event")
    func trackLoadMoreButtonTappedDispatchesCorrectEvent() {
        // When
        sut.trackLoadMoreButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_list_load_more_tapped", properties: [:]))
    }

    @Test("Track advanced search button tapped dispatches correct event")
    func trackAdvancedSearchButtonTappedDispatchesCorrectEvent() {
        // When
        sut.trackAdvancedSearchButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_list_advanced_search_tapped", properties: [:]))
    }
}
