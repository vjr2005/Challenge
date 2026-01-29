import ChallengeCore
import Testing

@testable import ChallengeSystem

struct NotFoundNavigatorTests {
    @Test
    func goBackCallsNavigator() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = NotFoundNavigator(navigator: navigatorMock)

        // When
        sut.goBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}
