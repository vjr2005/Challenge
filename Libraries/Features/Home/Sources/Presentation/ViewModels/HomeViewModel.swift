import ChallengeCharacter
import ChallengeCore

/// Not @Observable: no state for the view to observe, only exposes actions.
final class HomeViewModel {
	private let router: RouterContract

	init(router: RouterContract) {
		self.router = router
	}

	func didTapOnCharacterButton() {
		router.navigate(to: CharacterNavigation.list)
	}
}
