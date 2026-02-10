import ChallengeCore

struct CharacterEpisodesNavigator: CharacterEpisodesNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }
}
