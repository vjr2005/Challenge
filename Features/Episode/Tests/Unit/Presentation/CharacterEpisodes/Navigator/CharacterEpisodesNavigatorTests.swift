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

    // MARK: - Init Test

    @Test("Init does not crash")
    func initDoesNotCrash() {
        _ = sut
    }
}
