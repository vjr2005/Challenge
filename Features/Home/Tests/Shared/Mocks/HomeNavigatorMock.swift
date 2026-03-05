@testable import ChallengeHome

final class HomeNavigatorMock: HomeNavigatorContract, @unchecked Sendable {
    private(set) var navigateToCharactersCallCount = 0
    private(set) var presentAboutCallCount = 0

    func navigateToCharacters() {
        navigateToCharactersCallCount += 1
    }

    func presentAbout() {
        presentAboutCallCount += 1
    }

    // MARK: - Reset

    func reset() {
        navigateToCharactersCallCount = 0
        presentAboutCallCount = 0
    }
}
