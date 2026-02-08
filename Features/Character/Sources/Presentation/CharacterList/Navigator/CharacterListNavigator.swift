import ChallengeCore

struct CharacterListNavigator: CharacterListNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToDetail(identifier: Int) {
        navigator.navigate(to: CharacterIncomingNavigation.detail(identifier: identifier))
    }

    func presentAdvancedSearch(delegate: any CharacterFilterDelegate) {
        navigator.present(
            CharacterIncomingNavigation.advancedSearch(delegate: delegate),
            style: .fullScreenCover
        )
    }
}
