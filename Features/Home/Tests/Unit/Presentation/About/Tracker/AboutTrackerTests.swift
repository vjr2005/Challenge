import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct AboutTrackerTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let sut: AboutTracker

    // MARK: - Initialization

    init() {
        sut = AboutTracker(tracker: trackerMock)
    }

    // MARK: - Tests

    @Test("Track screen viewed dispatches about viewed event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // Given
        let expectedEvent = TrackedEvent(name: "about_viewed", properties: [:])

        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents == [expectedEvent])
    }
}
