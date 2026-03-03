import ChallengeCore

struct AboutNavigator: AboutNavigatorContract {
    private let navigator: any NavigatorContract

    init(navigator: any NavigatorContract) {
        self.navigator = navigator
    }

    func dismiss() {
        navigator.dismiss()
    }
}
