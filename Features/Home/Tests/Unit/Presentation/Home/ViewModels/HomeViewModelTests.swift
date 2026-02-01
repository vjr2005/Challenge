import Testing

@testable import ChallengeHome

struct HomeViewModelTests {
    // MARK: - Properties

    private let navigatorMock = HomeNavigatorMock()
    private let sut: HomeViewModel

    // MARK: - Initialization

    init() {
        sut = HomeViewModel(navigator: navigatorMock)
    }

    // MARK: - Tests

    @Test("Tap on character button navigates to characters")
    func didTapOnCharacterButtonCallsNavigator() {
        // When
        sut.didTapOnCharacterButton()

        // Then
        #expect(navigatorMock.navigateToCharactersCallCount == 1)
    }
}
