import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterDetailNavigatorTests {
    @Test
    func goBackCallsRouter() {
        // Given
        let routerMock = RouterMock()
        let sut = CharacterDetailNavigator(router: routerMock)

        // When
        sut.goBack()

        // Then
        #expect(routerMock.goBackCallCount == 1)
    }
}
