import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeHome

@Suite(.timeLimit(.minutes(1)))
struct HomeNavigatorTests {
    @Test
    func navigateToCharactersUsesCorrectURL() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeNavigator(router: routerMock)
        let expected = URL(string: "challenge://character/list")

        // When
        sut.navigateToCharacters()

        // Then
        #expect(routerMock.navigatedURLs.first == expected)
    }

    @Test
    func navigateToCharactersCallsRouterOnce() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeNavigator(router: routerMock)

        // When
        sut.navigateToCharacters()

        // Then
        #expect(routerMock.navigatedURLs.count == 1)
    }
}
