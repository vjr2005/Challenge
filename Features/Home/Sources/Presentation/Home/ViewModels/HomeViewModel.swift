final class HomeViewModel: HomeViewModelContract {
	private let navigator: HomeNavigatorContract

	init(navigator: HomeNavigatorContract) {
		self.navigator = navigator
	}

	func didTapOnCharacterButton() {
		navigator.navigateToCharacters()
	}
}
