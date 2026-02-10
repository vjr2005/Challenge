import ChallengeCore

struct CharacterDetailNavigator: CharacterDetailNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func goBack() {
        navigator.goBack()
    }

    func navigateToEpisodes(characterIdentifier: Int) {
        navigator.navigate(to: CharacterOutgoingNavigation.episodes(characterIdentifier: characterIdentifier))
    }
}
