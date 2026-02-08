import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterFilterTrackerTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let sut: CharacterFilterTracker

    // MARK: - Initialization

    init() {
        sut = CharacterFilterTracker(tracker: trackerMock)
    }

    // MARK: - Tests

    @Test("Track screen viewed dispatches character filter viewed event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_filter_viewed", properties: [:]))
    }

    @Test("Track apply filters dispatches event with filter count")
    func trackApplyFiltersDispatchesCorrectEvent() {
        // When
        sut.trackApplyFilters(filterCount: 3)

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_filter_filters_applied", properties: ["filter_count": "3"]))
    }

    @Test("Track reset filters dispatches correct event")
    func trackResetFiltersDispatchesCorrectEvent() {
        // When
        sut.trackResetFilters()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_filter_filters_reset", properties: [:]))
    }

    @Test("Track close tapped dispatches correct event")
    func trackCloseTappedDispatchesCorrectEvent() {
        // When
        sut.trackCloseTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "character_filter_close_tapped", properties: [:]))
    }
}
