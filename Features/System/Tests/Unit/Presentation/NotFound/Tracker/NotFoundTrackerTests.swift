import ChallengeCoreMocks
import Testing

@testable import ChallengeSystem

struct NotFoundTrackerTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let sut: NotFoundTracker

    // MARK: - Initialization

    init() {
        sut = NotFoundTracker(tracker: trackerMock)
    }

    // MARK: - Tests

    @Test("Track screen viewed dispatches not found viewed event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "not_found_viewed", properties: [:]))
    }

    @Test("Track go back button tapped dispatches correct event")
    func trackGoBackButtonTappedDispatchesCorrectEvent() {
        // When
        sut.trackGoBackButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "not_found_go_back_tapped", properties: [:]))
    }
}
