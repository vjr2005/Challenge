import ChallengeCore

struct AboutNavigator: AboutNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func dismiss() {
        navigator.dismiss()
    }
}
