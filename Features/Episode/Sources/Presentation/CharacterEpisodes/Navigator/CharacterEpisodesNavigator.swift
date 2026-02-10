import ChallengeCore

struct CharacterEpisodesNavigator: CharacterEpisodesNavigatorContract {
	private let navigator: NavigatorContract

	init(navigator: NavigatorContract) {
		self.navigator = navigator
	}

	func navigateToCharacterDetail(identifier: Int) {
		navigator.navigate(to: EpisodeOutgoingNavigation.characterDetail(identifier: identifier))
	}
}
