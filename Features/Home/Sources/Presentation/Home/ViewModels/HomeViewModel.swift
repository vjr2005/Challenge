final class HomeViewModel: HomeViewModelContract {
    private let navigator: any HomeNavigatorContract
    private let tracker: any HomeTrackerContract

    init(navigator: any HomeNavigatorContract, tracker: any HomeTrackerContract) {
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

    func didTapOnInfoButton() {
        tracker.trackInfoButtonTapped()
        navigator.presentAbout()
    }
}
