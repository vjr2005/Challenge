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

    // MARK: - Tests

    @Test("Tap on character button navigates to characters")
    func didTapOnCharacterButtonCallsNavigator() {
        // When
        sut.didTapOnCharacterButton()

        // Then
        #expect(navigatorMock.navigateToCharactersCallCount == 1)
    }

    // MARK: - Tracking

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    @Test("didTapOnCharacterButton tracks character button tapped")
    func didTapOnCharacterButtonTracksCharacterButtonTapped() {
        // When
        sut.didTapOnCharacterButton()

        // Then
        #expect(trackerMock.characterButtonTappedCallCount == 1)
    }
}
