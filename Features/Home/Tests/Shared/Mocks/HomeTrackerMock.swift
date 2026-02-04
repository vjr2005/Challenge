@testable import ChallengeHome

final class HomeTrackerMock: HomeTrackerContract {
    private(set) var screenViewedCallCount = 0
    private(set) var characterButtonTappedCallCount = 0

    func trackScreenViewed() {
        screenViewedCallCount += 1
    }

    func trackCharacterButtonTapped() {
        characterButtonTappedCallCount += 1
    }
}
