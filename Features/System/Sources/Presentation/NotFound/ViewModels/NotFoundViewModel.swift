final class NotFoundViewModel: NotFoundViewModelContract {
    private let navigator: NotFoundNavigatorContract
    private let tracker: NotFoundTrackerContract

    init(navigator: NotFoundNavigatorContract, tracker: NotFoundTrackerContract) {
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }

    func didTapGoBack() {
        tracker.trackGoBackButtonTapped()
        navigator.goBack()
    }
}
