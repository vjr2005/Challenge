@testable import ChallengeCharacter

final class CharacterListNavigatorMock: CharacterListNavigatorContract {
    private(set) var navigateToDetailIds: [Int] = []

    func navigateToDetail(id: Int) {
        navigateToDetailIds.append(id)
    }
}
