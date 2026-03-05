@testable import ChallengeSystem

final class NotFoundTrackerMock: NotFoundTrackerContract {
    private(set) var screenViewedCallCount = 0
    private(set) var goBackButtonTappedCallCount = 0

    func trackScreenViewed() {
        screenViewedCallCount += 1
    }

    func trackGoBackButtonTapped() {
        goBackButtonTappedCallCount += 1
    }

    // MARK: - Reset

    func reset() {
        screenViewedCallCount = 0
        goBackButtonTappedCallCount = 0
    }
}
