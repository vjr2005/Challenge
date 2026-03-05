@testable import ChallengeCharacter

final class CharacterDetailNavigatorMock: CharacterDetailNavigatorContract {
    private(set) var navigateToEpisodesCallCount = 0
    private(set) var lastNavigateToEpisodesCharacterIdentifier: Int?

    func navigateToEpisodes(characterIdentifier: Int) {
        navigateToEpisodesCallCount += 1
        lastNavigateToEpisodesCharacterIdentifier = characterIdentifier
    }
}
