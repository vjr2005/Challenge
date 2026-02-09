import ChallengeCore

struct EpisodeListNavigator: EpisodeListNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }
}
