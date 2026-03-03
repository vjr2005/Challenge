import ChallengeCore

struct CharacterEpisodesNavigator: CharacterEpisodesNavigatorContract {
	private let navigator: any NavigatorContract

	init(navigator: any NavigatorContract) {
		self.navigator = navigator
	}

	func navigateToCharacterDetail(identifier: Int) {
		navigator.navigate(to: EpisodeOutgoingNavigation.characterDetail(identifier: identifier))
	}
}
