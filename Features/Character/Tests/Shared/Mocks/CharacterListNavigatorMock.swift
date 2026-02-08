@testable import ChallengeCharacter

final class CharacterListNavigatorMock: CharacterListNavigatorContract {
    private(set) var navigateToDetailIdentifiers: [Int] = []
    private(set) var presentCharacterFilterCallCount = 0
    private(set) var lastPresentCharacterFilterDelegate: (any CharacterFilterDelegate)?

    func navigateToDetail(identifier: Int) {
        navigateToDetailIdentifiers.append(identifier)
    }

    func presentCharacterFilter(delegate: any CharacterFilterDelegate) {
        presentCharacterFilterCallCount += 1
        lastPresentCharacterFilterDelegate = delegate
    }
}
