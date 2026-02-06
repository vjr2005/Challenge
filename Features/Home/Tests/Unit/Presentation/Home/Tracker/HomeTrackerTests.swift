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
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "home_viewed", properties: [:]))
    }

    @Test("Track character button tapped dispatches correct event")
    func trackCharacterButtonTappedDispatchesCorrectEvent() {
        // When
        sut.trackCharacterButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "home_character_button_tapped", properties: [:]))
    }

    @Test("Track info button tapped dispatches correct event")
    func trackInfoButtonTappedDispatchesCorrectEvent() {
        // When
        sut.trackInfoButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "home_info_button_tapped", properties: [:]))
    }
}
