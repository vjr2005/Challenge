@testable import ChallengeCharacter

final class AdvancedSearchNavigatorMock: AdvancedSearchNavigatorContract {
    private(set) var dismissCallCount = 0

    func dismiss() {
        dismissCallCount += 1
    }
}
