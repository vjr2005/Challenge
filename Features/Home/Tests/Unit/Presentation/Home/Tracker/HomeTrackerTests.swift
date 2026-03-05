import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeTrackerTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let sut: HomeTracker

    // MARK: - Initialization

    init() {
        sut = HomeTracker(tracker: trackerMock)
    }

    // MARK: - Tests

    @Test("Track screen viewed dispatches home viewed event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "home_viewed", properties: [:])

        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track character button tapped dispatches correct event")
    func trackCharacterButtonTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "home_character_button_tapped", properties: [:])

        // When
        sut.trackCharacterButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track info button tapped dispatches correct event")
    func trackInfoButtonTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "home_info_button_tapped", properties: [:])

        // When
        sut.trackInfoButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }
}
