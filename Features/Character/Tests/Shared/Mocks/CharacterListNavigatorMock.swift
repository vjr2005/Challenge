@testable import ChallengeCharacter

final class CharacterListNavigatorMock: CharacterListNavigatorContract {
    private(set) var navigateToDetailIdentifiers: [Int] = []
    private(set) var presentAdvancedSearchCallCount = 0

    func navigateToDetail(identifier: Int) {
        navigateToDetailIdentifiers.append(identifier)
    }

    func presentAdvancedSearch() {
        presentAdvancedSearchCallCount += 1
    }
}
