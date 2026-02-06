import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterListNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: CharacterListNavigator

    // MARK: - Initialization

    init() {
        sut = CharacterListNavigator(navigator: navigatorMock)
    }

    // MARK: - Tests

    @Test("Navigate to detail uses correct navigation with identifier")
    func navigateToDetailUsesCorrectNavigation() {
        // Given
        let expected = CharacterIncomingNavigation.detail(identifier: 42)

        // When
        sut.navigateToDetail(identifier: 42)

        // Then
        #expect(navigatorMock.navigatedDestinations.count == 1)
        let destination = navigatorMock.navigatedDestinations.first as? CharacterIncomingNavigation
        #expect(destination == expected)
    }

    @Test("Present advanced search presents full screen cover")
    func presentAdvancedSearchPresentsFullScreenCover() {
        // When
        sut.presentAdvancedSearch()

        // Then
        #expect(navigatorMock.presentedModals.count == 1)
        let modal = navigatorMock.presentedModals.first
        let destination = modal?.destination as? CharacterIncomingNavigation
        #expect(destination == .advancedSearch)
        #expect(modal?.style == .fullScreenCover)
    }
}
