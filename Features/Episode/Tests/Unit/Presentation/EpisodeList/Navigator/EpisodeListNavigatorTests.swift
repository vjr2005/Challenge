import ChallengeCoreMocks
import Testing

@testable import ChallengeEpisode

struct EpisodeListNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: EpisodeListNavigator

    // MARK: - Init

    init() {
        sut = EpisodeListNavigator(navigator: navigatorMock)
    }

    // MARK: - Init Test

    @Test("Init does not crash")
    func initDoesNotCrash() {
        _ = sut
    }
}
