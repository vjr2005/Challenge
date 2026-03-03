import ChallengeCore

struct NotFoundNavigator: NotFoundNavigatorContract {
    private let navigator: any NavigatorContract

    init(navigator: any NavigatorContract) {
        self.navigator = navigator
    }

    func goBack() {
        navigator.goBack()
    }
}
