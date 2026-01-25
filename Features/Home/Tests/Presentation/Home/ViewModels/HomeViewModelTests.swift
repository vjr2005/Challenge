import Testing

@testable import ChallengeHome

@Suite(.timeLimit(.minutes(1)))
struct HomeViewModelTests {
    @Test
    func didTapOnCharacterButtonCallsNavigator() {
        // Given
        let navigatorMock = HomeNavigatorMock()
        let sut = HomeViewModel(navigator: navigatorMock)

        // When
        sut.didTapOnCharacterButton()

        // Then
        #expect(navigatorMock.navigateToCharactersCallCount == 1)
    }
}
