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
        // Given
        let expectedEvent = TrackedEvent(name: "character_filter_viewed", properties: [:])

        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track apply filters dispatches event with filter count")
    func trackApplyFiltersDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_filter_filters_applied", properties: ["filter_count": "3"])

        // When
        sut.trackApplyFilters(filterCount: 3)

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track reset filters dispatches correct event")
    func trackResetFiltersDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_filter_filters_reset", properties: [:])

        // When
        sut.trackResetFilters()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track close tapped dispatches correct event")
    func trackCloseTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "character_filter_close_tapped", properties: [:])

        // When
        sut.trackCloseTapped()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }
}
