@testable import ChallengeHome

final class AboutTrackerMock: AboutTrackerContract {
    private(set) var screenViewedCallCount = 0

    func trackScreenViewed() {
        screenViewedCallCount += 1
    }

    // MARK: - Reset

    func reset() {
        screenViewedCallCount = 0
    }
}
