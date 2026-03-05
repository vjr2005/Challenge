@testable import ChallengeHome

final class AboutTrackerMock: AboutTrackerContract {
    private(set) var screenViewedCallCount = 0

    func trackScreenViewed() {
        screenViewedCallCount += 1
    }
}
