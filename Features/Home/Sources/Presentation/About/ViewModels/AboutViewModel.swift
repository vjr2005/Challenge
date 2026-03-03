final class AboutViewModel: AboutViewModelContract {
	let info: AboutInfo
	private let navigator: any AboutNavigatorContract
	private let tracker: any AboutTrackerContract

	init(
		getAboutInfoUseCase: any GetAboutInfoUseCaseContract,
		navigator: any AboutNavigatorContract,
		tracker: any AboutTrackerContract
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
