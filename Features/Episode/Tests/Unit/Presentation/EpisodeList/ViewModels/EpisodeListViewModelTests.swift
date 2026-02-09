import Testing

@testable import ChallengeEpisode

struct EpisodeListViewModelTests {
    // MARK: - Properties

    private let navigatorMock = EpisodeListNavigatorMock()
    private let trackerMock = EpisodeListTrackerMock()
    private let sut: EpisodeListViewModel

    // MARK: - Init

    init() {
        sut = EpisodeListViewModel(
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    // MARK: - Did Appear

    @Test("Did appear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.trackScreenViewedCallCount == 1)
    }
}
