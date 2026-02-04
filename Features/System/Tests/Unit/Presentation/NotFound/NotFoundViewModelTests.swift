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

    // MARK: - Tests

    @Test("Tap go back delegates to navigator")
    func didTapGoBackCallsNavigator() {
        // When
        sut.didTapGoBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }

    // MARK: - Tracking

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    @Test("didTapGoBack tracks go back button tapped")
    func didTapGoBackTracksGoBackButtonTapped() {
        // When
        sut.didTapGoBack()

        // Then
        #expect(trackerMock.goBackButtonTappedCallCount == 1)
    }
}
