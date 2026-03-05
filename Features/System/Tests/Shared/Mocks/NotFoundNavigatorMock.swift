@testable import ChallengeSystem

final class NotFoundNavigatorMock: NotFoundNavigatorContract {
    private(set) var goBackCallCount = 0

    func goBack() {
        goBackCallCount += 1
    }
}
