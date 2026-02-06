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

    @Test("Navigate to characters uses correct navigation destination")
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

    @Test("Present about uses correct navigation and style")
    func presentAboutUsesCorrectNavigationAndStyle() {
        // When
        sut.presentAbout()

        // Then
        #expect(navigatorMock.presentedModals.count == 1)
        let modal = navigatorMock.presentedModals.first
        let destination = modal?.destination as? HomeIncomingNavigation
        #expect(destination == .about)
        #expect(modal?.style == .sheet(detents: [.medium, .large]))
    }
}
