final class HomeViewModel: HomeViewModelContract {
    private let navigator: HomeNavigatorContract
    private let tracker: HomeTrackerContract

    init(navigator: HomeNavigatorContract, tracker: HomeTrackerContract) {
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }

    func didTapOnCharacterButton() {
        tracker.trackCharacterButtonTapped()
        navigator.navigateToCharacters()
    }
}
