import Testing

@testable import ChallengeHome

struct AboutViewModelTests {
	// MARK: - Properties

	private let useCaseMock = GetAboutInfoUseCaseMock()
	private let navigatorMock = AboutNavigatorMock()
	private let trackerMock = AboutTrackerMock()
	private let sut: AboutViewModel

	// MARK: - Initialization

	init() {
		useCaseMock.result = GetAboutInfoUseCase().execute()
		sut = AboutViewModel(
			getAboutInfoUseCase: useCaseMock,
			navigator: navigatorMock,
			tracker: trackerMock
		)
	}

	// MARK: - Info

	@Test("Info is populated from use case on init")
	func infoIsPopulated() {
		// Then
		#expect(sut.info == useCaseMock.result)
		#expect(useCaseMock.executeCallCount == 1)
	}

	// MARK: - Navigation

	@Test("Tap on close button dismisses")
	func didTapCloseCallsDismiss() {
		// When
		sut.didTapClose()

		// Then
		#expect(navigatorMock.dismissCallCount == 1)
	}

	// MARK: - Tracking

	@Test("didAppear tracks screen viewed")
	func didAppearTracksScreenViewed() {
		// When
		sut.didAppear()

		// Then
		#expect(trackerMock.screenViewedCallCount == 1)
	}
}
