import ChallengeCore

struct CharacterDetailNavigator: CharacterDetailNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func goBack() {
        navigator.goBack()
    }
}
