import ChallengeCore

struct CharacterListNavigator: CharacterListNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToDetail(identifier: Int) {
        navigator.navigate(to: CharacterIncomingNavigation.detail(identifier: identifier))
    }
}
