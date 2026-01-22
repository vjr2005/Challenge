@testable import ChallengeCharacter

final class CharacterDetailNavigatorMock: CharacterDetailNavigatorContract {
    private(set) var goBackCallCount = 0

    func goBack() {
        goBackCallCount += 1
    }
}
