import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterDetailNavigatorTests {
    @Test
    func goBackCallsNavigator() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = CharacterDetailNavigator(navigator: navigatorMock)

        // When
        sut.goBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}
