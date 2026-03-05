import Testing

@testable import ChallengeHome

struct HomeViewModelTests {
    // MARK: - Properties

    private let navigatorMock = HomeNavigatorMock()
    private let trackerMock = HomeTrackerMock()
    private let sut: HomeViewModel

    // MARK: - Initialization

    init() {
        sut = HomeViewModel(navigator: navigatorMock, tracker: trackerMock)
    }

    // MARK: - didAppear

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    // MARK: - didTapOnCharacterButton

    @Test("didTapOnCharacterButton navigates to characters and tracks event")
    func didTapOnCharacterButton() {
        // When
        sut.didTapOnCharacterButton()

        // Then
        #expect(navigatorMock.navigateToCharactersCallCount == 1)
        #expect(trackerMock.characterButtonTappedCallCount == 1)
    }

    // MARK: - didTapOnInfoButton

    @Test("didTapOnInfoButton presents about and tracks event")
    func didTapOnInfoButton() {
        // When
        sut.didTapOnInfoButton()

        // Then
        #expect(navigatorMock.presentAboutCallCount == 1)
        #expect(trackerMock.infoButtonTappedCallCount == 1)
    }
}
