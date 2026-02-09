@testable import ChallengeEpisode

final class EpisodeListTrackerMock: EpisodeListTrackerContract {
    private(set) var trackScreenViewedCallCount = 0

    func trackScreenViewed() {
        trackScreenViewedCallCount += 1
    }
}
