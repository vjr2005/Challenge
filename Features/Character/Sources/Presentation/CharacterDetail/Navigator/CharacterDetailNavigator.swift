import ChallengeCore

struct CharacterDetailNavigator: CharacterDetailNavigatorContract {
    private let navigator: any NavigatorContract

    init(navigator: any NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToEpisodes(characterIdentifier: Int) {
        navigator.navigate(to: CharacterOutgoingNavigation.episodes(characterIdentifier: characterIdentifier))
    }
}
