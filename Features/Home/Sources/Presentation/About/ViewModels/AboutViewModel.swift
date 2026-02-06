final class AboutViewModel: AboutViewModelContract {
    private let navigator: AboutNavigatorContract
    private let tracker: AboutTrackerContract

    init(navigator: AboutNavigatorContract, tracker: AboutTrackerContract) {
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() {
        tracker.trackScreenViewed()
    }

    func didTapClose() {
        navigator.dismiss()
    }
}
