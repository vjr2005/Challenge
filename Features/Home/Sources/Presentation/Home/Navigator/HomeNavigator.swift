import ChallengeCore

struct HomeNavigator: HomeNavigatorContract {
    private let navigator: any NavigatorContract

    init(navigator: any NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToCharacters() {
        navigator.navigate(to: HomeOutgoingNavigation.characters)
    }

    func presentAbout() {
        navigator.present(
            HomeIncomingNavigation.about,
            style: .sheet(detents: [.medium, .large])
        )
    }
}
