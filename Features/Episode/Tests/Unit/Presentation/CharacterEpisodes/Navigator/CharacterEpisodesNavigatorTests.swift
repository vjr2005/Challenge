import ChallengeCoreMocks
import Testing

@testable import ChallengeEpisode

struct CharacterEpisodesNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: CharacterEpisodesNavigator

    // MARK: - Init

    init() {
        sut = CharacterEpisodesNavigator(navigator: navigatorMock)
    }

    // MARK: - Navigate To Character Detail

    @Test("Navigate to character detail uses correct navigation destination")
    func navigateToCharacterDetailUsesCorrectNavigation() {
        // Given
        let identifier = 42

        // When
        sut.navigateToCharacterDetail(identifier: identifier)

        // Then
        #expect(navigatorMock.navigatedDestinations.count == 1)
        let destination = navigatorMock.navigatedDestinations.first as? EpisodeOutgoingNavigation
        #expect(destination == .characterDetail(identifier: identifier))
    }
}
