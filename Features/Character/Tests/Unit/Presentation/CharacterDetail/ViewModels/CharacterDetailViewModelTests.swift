import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterDetailViewModelTests {
    // MARK: - Properties

    private let identifier = 1
    private let getCharacterUseCaseMock = GetCharacterUseCaseMock()
    private let refreshCharacterUseCaseMock = RefreshCharacterUseCaseMock()
    private let navigatorMock = CharacterDetailNavigatorMock()
    private let trackerMock = CharacterDetailTrackerMock()
    private let sut: CharacterDetailViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: getCharacterUseCaseMock,
            refreshCharacterUseCase: refreshCharacterUseCaseMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    // MARK: - Initial State

    @Test("Initial state is idle before loading")
    func initialStateIsIdle() {
        // Then
        #expect(sut.state == .idle)
    }

    // MARK: - didAppear

    @Test("didAppear sets loaded state with character on success")
    func didAppearSetsLoadedStateOnSuccess() async {
        // Given
        let expected = Character.stub()
        getCharacterUseCaseMock.result = .success(expected)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("didAppear sets error state on failure")
    func didAppearSetsErrorStateOnFailure() async {
        // Given
        getCharacterUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .error(.loadFailed()))
    }

    @Test("didAppear calls use case with correct character identifier")
    func didAppearCallsUseCaseWithCorrectIdentifier() async {
        // Given
        getCharacterUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(getCharacterUseCaseMock.executeCallCount == 1)
        #expect(getCharacterUseCaseMock.lastRequestedIdentifier == identifier)
    }

    // MARK: - didTapOnRetryButton

    @Test("didTapOnRetryButton retries loading when in error state")
    func didTapOnRetryButtonRetriesWhenError() async {
        // Given
        getCharacterUseCaseMock.result = .failure(.loadFailed())
        await sut.didAppear()

        // When
        getCharacterUseCaseMock.result = .success(.stub())
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharacterUseCaseMock.executeCallCount == 2)
    }

    @Test("didTapOnRetryButton always loads regardless of current state")
    func didTapOnRetryButtonAlwaysLoads() async {
        // Given
        getCharacterUseCaseMock.result = .success(.stub())
        await sut.didAppear()
        #expect(getCharacterUseCaseMock.executeCallCount == 1)

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharacterUseCaseMock.executeCallCount == 2)
    }

    // MARK: - Navigation

    @Test("Tap on back navigates back")
    func didTapOnBackCallsNavigatorGoBack() {
        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }

    @Test("Tap on episodes navigates to episodes with correct identifier")
    func didTapOnEpisodesNavigatesToEpisodes() {
        // When
        sut.didTapOnEpisodes()

        // Then
        #expect(navigatorMock.navigateToEpisodesCallCount == 1)
        #expect(navigatorMock.lastNavigateToEpisodesCharacterIdentifier == identifier)
    }

    // MARK: - didPullToRefresh

    @Test("didPullToRefresh updates character with fresh data from API")
    func didPullToRefreshUpdatesCharacterFromAPI() async {
        // Given
        let initialCharacter = Character.stub(name: "Initial")
        let refreshedCharacter = Character.stub(name: "Refreshed")
        getCharacterUseCaseMock.result = .success(initialCharacter)
        await sut.didAppear()
        refreshCharacterUseCaseMock.result = .success(refreshedCharacter)

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharacterUseCaseMock.executeCallCount == 1)
        #expect(sut.state == .loaded(refreshedCharacter))
    }

    @Test("didPullToRefresh calls use case with correct character identifier")
    func didPullToRefreshCallsUseCaseWithCorrectIdentifier() async {
        // Given
        refreshCharacterUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharacterUseCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("didPullToRefresh sets error state on failure")
    func didPullToRefreshSetsErrorStateOnFailure() async {
        // Given
        refreshCharacterUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(sut.state == .error(.loadFailed()))
    }

    @Test("didPullToRefresh keeps loaded state visible during network request")
    func didPullToRefreshKeepsLoadedStateDuringRequest() async {
        // Given
        let loadedCharacter = Character.stub()
        getCharacterUseCaseMock.result = .success(loadedCharacter)
        await sut.didAppear()
        refreshCharacterUseCaseMock.result = .success(.stub())

        var statesDuringRefresh: [CharacterDetailViewState] = []
        refreshCharacterUseCaseMock.onExecute = { [weak sut] in
            guard let sut else { return }
            statesDuringRefresh.append(sut.state)
        }

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(statesDuringRefresh.count == 1)
        #expect(statesDuringRefresh.first == .loaded(loadedCharacter))
    }

    // MARK: - Tracking

    @Test("didAppear tracks screen viewed with identifier")
    func didAppearTracksScreenViewed() async {
        // Given
        getCharacterUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedIdentifiers == [identifier])
    }

    @Test("didTapOnRetryButton tracks retry button tapped")
    func didTapOnRetryButtonTracksRetryButtonTapped() async {
        // Given
        getCharacterUseCaseMock.result = .success(.stub())

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(trackerMock.retryButtonTappedCallCount == 1)
    }

    @Test("didPullToRefresh tracks pull to refresh triggered")
    func didPullToRefreshTracksPullToRefreshTriggered() async {
        // Given
        refreshCharacterUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(trackerMock.pullToRefreshTriggeredCallCount == 1)
    }

    @Test("didTapOnBack tracks back button tapped")
    func didTapOnBackTracksBackButtonTapped() {
        // When
        sut.didTapOnBack()

        // Then
        #expect(trackerMock.backButtonTappedCallCount == 1)
    }

    @Test("didTapOnEpisodes tracks episodes button tapped with identifier")
    func didTapOnEpisodesTracksEpisodesButtonTapped() {
        // When
        sut.didTapOnEpisodes()

        // Then
        #expect(trackerMock.episodesButtonTappedIdentifiers == [identifier])
    }

    // MARK: - Error Tracking

    @Test("didAppear tracks load error on failure")
    func didAppearTracksLoadErrorOnFailure() async {
        // Given
        getCharacterUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.loadErrorDescriptions.count == 1)
        #expect(trackerMock.loadErrorDescriptions.first == CharacterError.loadFailed().debugDescription)
    }

    @Test("didAppear does not track load error on success")
    func didAppearDoesNotTrackLoadErrorOnSuccess() async {
        // Given
        getCharacterUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.loadErrorDescriptions.isEmpty)
    }

    @Test("didPullToRefresh tracks refresh error on failure")
    func didPullToRefreshTracksRefreshErrorOnFailure() async {
        // Given
        refreshCharacterUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(trackerMock.refreshErrorDescriptions.count == 1)
        #expect(trackerMock.refreshErrorDescriptions.first == CharacterError.loadFailed().debugDescription)
    }

    @Test("didPullToRefresh does not track refresh error on success")
    func didPullToRefreshDoesNotTrackRefreshErrorOnSuccess() async {
        // Given
        refreshCharacterUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(trackerMock.refreshErrorDescriptions.isEmpty)
    }
}
