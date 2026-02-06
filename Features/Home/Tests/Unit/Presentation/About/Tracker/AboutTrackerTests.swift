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
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "about_viewed", properties: [:]))
    }
}
