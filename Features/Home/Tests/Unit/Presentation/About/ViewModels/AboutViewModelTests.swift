import Testing

@testable import ChallengeHome

struct AboutViewModelTests {
    // MARK: - Properties

    private let navigatorMock = AboutNavigatorMock()
    private let trackerMock = AboutTrackerMock()
    private let sut: AboutViewModel

    // MARK: - Initialization

    init() {
        sut = AboutViewModel(navigator: navigatorMock, tracker: trackerMock)
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
