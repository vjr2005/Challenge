import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: HomeNavigator

    // MARK: - Initialization

    init() {
        sut = HomeNavigator(navigator: navigatorMock)
    }

    // MARK: - Tests

    @Test
    func navigateToCharactersUsesCorrectNavigation() {
        // Given
        let expected = HomeOutgoingNavigation.characters

        // When
        sut.navigateToCharacters()

        // Then
        #expect(navigatorMock.navigatedDestinations.count == 1)
        let destination = navigatorMock.navigatedDestinations.first as? HomeOutgoingNavigation
        #expect(destination == expected)
    }
}
