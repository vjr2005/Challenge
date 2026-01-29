import ChallengeCore

struct NotFoundNavigator: NotFoundNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func goBack() {
        navigator.goBack()
    }
}
