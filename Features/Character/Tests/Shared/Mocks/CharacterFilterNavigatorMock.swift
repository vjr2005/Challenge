@testable import ChallengeCharacter

final class CharacterFilterNavigatorMock: CharacterFilterNavigatorContract {
    private(set) var dismissCallCount = 0

    func dismiss() {
        dismissCallCount += 1
    }
}
