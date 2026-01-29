import Testing

@testable import ChallengeSystem

struct NotFoundViewModelTests {
    @Test
    func didTapGoBackCallsNavigator() {
        // Given
        let navigatorMock = NotFoundNavigatorMock()
        let sut = NotFoundViewModel(navigator: navigatorMock)

        // When
        sut.didTapGoBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}
