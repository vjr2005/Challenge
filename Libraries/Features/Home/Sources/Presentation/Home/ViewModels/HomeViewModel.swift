/// Not @Observable: no state for the view to observe, only exposes actions.
final class HomeViewModel {
    private let navigator: HomeNavigatorContract

    init(navigator: HomeNavigatorContract) {
        self.navigator = navigator
    }

    func didTapOnCharacterButton() {
        navigator.navigateToCharacters()
    }
}
