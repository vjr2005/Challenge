import ChallengeCore

struct CharacterDetailNavigator: CharacterDetailNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToEpisodes(characterIdentifier: Int) {
        navigator.navigate(to: CharacterOutgoingNavigation.episodes(characterIdentifier: characterIdentifier))
    }
}
