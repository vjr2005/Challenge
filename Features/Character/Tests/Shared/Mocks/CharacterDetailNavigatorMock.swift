@testable import ChallengeCharacter

final class CharacterDetailNavigatorMock: CharacterDetailNavigatorContract {
    private(set) var goBackCallCount = 0
    private(set) var navigateToEpisodesCallCount = 0
    private(set) var lastNavigateToEpisodesCharacterIdentifier: Int?

    func goBack() {
        goBackCallCount += 1
    }

    func navigateToEpisodes(characterIdentifier: Int) {
        navigateToEpisodesCallCount += 1
        lastNavigateToEpisodesCharacterIdentifier = characterIdentifier
    }
}
