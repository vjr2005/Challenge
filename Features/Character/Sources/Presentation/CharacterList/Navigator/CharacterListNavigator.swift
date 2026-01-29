import ChallengeCore

struct CharacterListNavigator: CharacterListNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToDetail(id: Int) {
        navigator.navigate(to: CharacterIncomingNavigation.detail(identifier: id))
    }
}
