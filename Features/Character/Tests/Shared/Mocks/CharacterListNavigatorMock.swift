@testable import ChallengeCharacter

final class CharacterListNavigatorMock: CharacterListNavigatorContract {
    private(set) var navigateToDetailIdentifiers: [Int] = []

    func navigateToDetail(identifier: Int) {
        navigateToDetailIdentifiers.append(identifier)
    }
}
