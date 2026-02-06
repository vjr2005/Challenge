import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct AdvancedSearchTrackerTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let sut: AdvancedSearchTracker

    // MARK: - Initialization

    init() {
        sut = AdvancedSearchTracker(tracker: trackerMock)
    }

    // MARK: - Tests

    @Test("Track screen viewed dispatches advanced search viewed event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "advanced_search_viewed", properties: [:]))
    }

    @Test("Track apply filters dispatches event with filter count")
    func trackApplyFiltersDispatchesCorrectEvent() {
        // When
        sut.trackApplyFilters(filterCount: 3)

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "advanced_search_filters_applied", properties: ["filter_count": "3"]))
    }

    @Test("Track reset filters dispatches correct event")
    func trackResetFiltersDispatchesCorrectEvent() {
        // When
        sut.trackResetFilters()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "advanced_search_filters_reset", properties: [:]))
    }

    @Test("Track close tapped dispatches correct event")
    func trackCloseTappedDispatchesCorrectEvent() {
        // When
        sut.trackCloseTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "advanced_search_close_tapped", properties: [:]))
    }
}
