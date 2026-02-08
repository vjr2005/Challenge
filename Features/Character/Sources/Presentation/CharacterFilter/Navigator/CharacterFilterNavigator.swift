import ChallengeCore

struct CharacterFilterNavigator: CharacterFilterNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func dismiss() {
        navigator.dismiss()
    }
}
