import ChallengeCore

struct AdvancedSearchNavigator: AdvancedSearchNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func dismiss() {
        navigator.dismiss()
    }
}
