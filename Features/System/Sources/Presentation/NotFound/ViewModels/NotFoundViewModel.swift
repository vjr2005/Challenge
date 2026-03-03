final class NotFoundViewModel: NotFoundViewModelContract {
    private let navigator: any NotFoundNavigatorContract
    private let tracker: any NotFoundTrackerContract

    init(navigator: any NotFoundNavigatorContract, tracker: any NotFoundTrackerContract) {
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
