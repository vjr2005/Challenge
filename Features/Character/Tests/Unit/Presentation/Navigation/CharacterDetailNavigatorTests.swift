import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterDetailNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: CharacterDetailNavigator

    // MARK: - Initialization

    init() {
        sut = CharacterDetailNavigator(navigator: navigatorMock)
    }

    // MARK: - Tests

    @Test("Go back delegates to navigator")
    func goBackCallsNavigator() {
        // When
        sut.goBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }

    @Test("Navigate to episodes uses correct navigation destination")
    func navigateToEpisodesUsesCorrectNavigation() {
        // Given
        let characterIdentifier = 42

        // When
        sut.navigateToEpisodes(characterIdentifier: characterIdentifier)

        // Then
        #expect(navigatorMock.navigatedDestinations.count == 1)
        let destination = navigatorMock.navigatedDestinations.first as? CharacterOutgoingNavigation
        #expect(destination == .episodes(characterIdentifier: characterIdentifier))
    }
}
