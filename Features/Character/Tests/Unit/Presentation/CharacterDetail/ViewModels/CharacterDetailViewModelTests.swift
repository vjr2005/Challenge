import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterDetailViewModelTests {
    // MARK: - Properties

    private let identifier = 1
    private let getCharacterDetailUseCaseMock = GetCharacterDetailUseCaseMock()
    private let refreshCharacterDetailUseCaseMock = RefreshCharacterDetailUseCaseMock()
    private let navigatorMock = CharacterDetailNavigatorMock()
    private let trackerMock = CharacterDetailTrackerMock()
    private let sut: CharacterDetailViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterDetailViewModel(
            identifier: identifier,
            getCharacterDetailUseCase: getCharacterDetailUseCaseMock,
            refreshCharacterDetailUseCase: refreshCharacterDetailUseCaseMock,
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
        getCharacterDetailUseCaseMock.result = .success(expected)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("didAppear sets error state on failure")
    func didAppearSetsErrorStateOnFailure() async {
        // Given
        getCharacterDetailUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("didAppear calls use case with correct character identifier")
    func didAppearCallsUseCaseWithCorrectIdentifier() async {
        // Given
        getCharacterDetailUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(getCharacterDetailUseCaseMock.executeCallCount == 1)
        #expect(getCharacterDetailUseCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("didAppear does nothing when already loaded")
    func didAppearDoesNothingWhenLoaded() async {
        // Given
        getCharacterDetailUseCaseMock.result = .success(.stub())
        await sut.didAppear()

        // When
        await sut.didAppear()

        // Then
        #expect(getCharacterDetailUseCaseMock.executeCallCount == 1)
    }

    @Test("didAppear does nothing when in error state")
    func didAppearDoesNothingWhenError() async {
        // Given
        getCharacterDetailUseCaseMock.result = .failure(.loadFailed)
        await sut.didAppear()

        // When
        await sut.didAppear()

        // Then
        #expect(getCharacterDetailUseCaseMock.executeCallCount == 1)
    }

    // MARK: - didTapOnRetryButton

    @Test("didTapOnRetryButton retries loading when in error state")
    func didTapOnRetryButtonRetriesWhenError() async {
        // Given
        getCharacterDetailUseCaseMock.result = .failure(.loadFailed)
        await sut.didAppear()

        // When
        getCharacterDetailUseCaseMock.result = .success(.stub())
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharacterDetailUseCaseMock.executeCallCount == 2)
    }

    @Test("didTapOnRetryButton always loads regardless of current state")
    func didTapOnRetryButtonAlwaysLoads() async {
        // Given
        getCharacterDetailUseCaseMock.result = .success(.stub())
        await sut.didAppear()
        #expect(getCharacterDetailUseCaseMock.executeCallCount == 1)

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharacterDetailUseCaseMock.executeCallCount == 2)
    }

    // MARK: - Navigation

    @Test("Tap on back navigates back")
    func didTapOnBackCallsNavigatorGoBack() {
        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }

    // MARK: - didPullToRefresh

    @Test("didPullToRefresh updates character with fresh data from API")
    func didPullToRefreshUpdatesCharacterFromAPI() async {
        // Given
        let initialCharacter = Character.stub(name: "Initial")
        let refreshedCharacter = Character.stub(name: "Refreshed")
        getCharacterDetailUseCaseMock.result = .success(initialCharacter)
        await sut.didAppear()
        refreshCharacterDetailUseCaseMock.result = .success(refreshedCharacter)

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharacterDetailUseCaseMock.executeCallCount == 1)
        #expect(sut.state == .loaded(refreshedCharacter))
    }

    @Test("didPullToRefresh calls use case with correct character identifier")
    func didPullToRefreshCallsUseCaseWithCorrectIdentifier() async {
        // Given
        refreshCharacterDetailUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharacterDetailUseCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("didPullToRefresh sets error state on failure")
    func didPullToRefreshSetsErrorStateOnFailure() async {
        // Given
        refreshCharacterDetailUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("didPullToRefresh keeps loaded state visible during network request")
    func didPullToRefreshKeepsLoadedStateDuringRequest() async {
        // Given
        let loadedCharacter = Character.stub()
        getCharacterDetailUseCaseMock.result = .success(loadedCharacter)
        await sut.didAppear()
        refreshCharacterDetailUseCaseMock.result = .success(.stub())

        var statesDuringRefresh: [CharacterDetailViewState] = []
        refreshCharacterDetailUseCaseMock.onExecute = { [weak sut] in
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
        getCharacterDetailUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedIdentifiers == [identifier])
    }

    @Test("didAppear does not track screen viewed when already loaded")
    func didAppearDoesNotTrackScreenViewedWhenAlreadyLoaded() async {
        // Given
        getCharacterDetailUseCaseMock.result = .success(.stub())
        await sut.didAppear()

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedIdentifiers == [identifier])
    }

    @Test("didTapOnRetryButton tracks retry button tapped")
    func didTapOnRetryButtonTracksRetryButtonTapped() async {
        // Given
        getCharacterDetailUseCaseMock.result = .success(.stub())

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(trackerMock.retryButtonTappedCallCount == 1)
    }

    @Test("didPullToRefresh tracks pull to refresh triggered")
    func didPullToRefreshTracksPullToRefreshTriggered() async {
        // Given
        refreshCharacterDetailUseCaseMock.result = .success(.stub())

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
}
