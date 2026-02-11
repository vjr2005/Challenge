final class AboutViewModel: AboutViewModelContract {
	let info: AboutInfo
	private let navigator: AboutNavigatorContract
	private let tracker: AboutTrackerContract

	init(
		getAboutInfoUseCase: GetAboutInfoUseCaseContract,
		navigator: AboutNavigatorContract,
		tracker: AboutTrackerContract
	) {
		info = getAboutInfoUseCase.execute()
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
