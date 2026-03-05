import Testing

@testable import ChallengeSystem

struct NotFoundViewModelTests {
    // MARK: - Properties

    private let navigatorMock = NotFoundNavigatorMock()
    private let trackerMock = NotFoundTrackerMock()
    private let sut: NotFoundViewModel

    // MARK: - Initialization

    init() {
        sut = NotFoundViewModel(navigator: navigatorMock, tracker: trackerMock)
    }

    // MARK: - didAppear

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    // MARK: - didTapGoBack

    @Test("didTapGoBack navigates back and tracks event")
    func didTapGoBack() {
        // When
        sut.didTapGoBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
        #expect(trackerMock.goBackButtonTappedCallCount == 1)
    }
}
