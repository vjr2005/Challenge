@testable import ChallengeCharacter

final class CharacterListNavigatorMock: CharacterListNavigatorContract {
    private(set) var navigateToDetailIdentifiers: [Int] = []
    private(set) var presentAdvancedSearchCallCount = 0
    private(set) var lastPresentAdvancedSearchDelegate: (any CharacterFilterDelegate)?

    func navigateToDetail(identifier: Int) {
        navigateToDetailIdentifiers.append(identifier)
    }

    func presentAdvancedSearch(delegate: any CharacterFilterDelegate) {
        presentAdvancedSearchCallCount += 1
        lastPresentAdvancedSearchDelegate = delegate
    }
}
