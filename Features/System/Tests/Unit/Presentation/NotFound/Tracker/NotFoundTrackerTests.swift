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
        // Given
        let expectedEvent = TrackedEvent(name: "not_found_viewed", properties: [:])

        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }

    @Test("Track go back button tapped dispatches correct event")
    func trackGoBackButtonTappedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "not_found_go_back_tapped", properties: [:])

        // When
        sut.trackGoBackButtonTapped()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }
}
