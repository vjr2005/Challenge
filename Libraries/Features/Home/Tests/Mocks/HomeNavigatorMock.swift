@testable import ChallengeHome

final class HomeNavigatorMock: HomeNavigatorContract {
    private(set) var navigateToCharactersCallCount = 0

    func navigateToCharacters() {
        navigateToCharactersCallCount += 1
    }
}
