@testable import ChallengeHome

final class AboutNavigatorMock: AboutNavigatorContract {
    private(set) var dismissCallCount = 0

    func dismiss() {
        dismissCallCount += 1
    }

    // MARK: - Reset

    func reset() {
        dismissCallCount = 0
    }
}
