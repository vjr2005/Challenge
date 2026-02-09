import ChallengeCoreMocks
import Testing

@testable import ChallengeEpisode

struct EpisodeListTrackerTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let sut: EpisodeListTracker

    // MARK: - Init

    init() {
        sut = EpisodeListTracker(tracker: trackerMock)
    }

    // MARK: - Track Screen Viewed

    @Test("Track screen viewed dispatches correct event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "episode_list_viewed", properties: [:]))
    }
}
