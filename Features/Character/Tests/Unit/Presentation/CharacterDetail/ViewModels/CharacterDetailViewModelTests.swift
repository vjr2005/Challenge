import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterDetailViewModelTests {
    // MARK: - Properties

    private let identifier = 1
    private let getCharacterUseCaseMock = GetCharacterUseCaseMock()
    private let refreshCharacterUseCaseMock = RefreshCharacterUseCaseMock()
    private let imageLoaderMock = ImageLoaderMock(cachedImage: nil, asyncImage: nil)
    private let navigatorMock = CharacterDetailNavigatorMock()
    private let trackerMock = CharacterDetailTrackerMock()
    private let sut: CharacterDetailViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: getCharacterUseCaseMock,
            refreshCharacterUseCase: refreshCharacterUseCaseMock,
            imageLoader: imageLoaderMock,
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

    @Test("didAppear produces expected outcome per scenario", arguments: DidAppearScenario.all)
    func didAppear(scenario: DidAppearScenario) async {
        // Given
        getCharacterUseCaseMock.result = scenario.given.characterResult

        // When
        await sut.didAppear()

        // Then
        #expect(getCharacterUseCaseMock.executeCallCount == 1)
        #expect(getCharacterUseCaseMock.lastRequestedIdentifier == identifier)
        #expect(trackerMock.screenViewedIdentifiers == [identifier])
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.loadErrorDescriptions == scenario.expected.loadErrorDescriptions)
    }

    // MARK: - didTapOnRetryButton

    @Test("didTapOnRetryButton produces expected outcome per scenario", arguments: DidTapOnRetryButtonScenario.all)
    func didTapOnRetryButton(scenario: DidTapOnRetryButtonScenario) async {
        // Given
        await givenErrorState()
        getCharacterUseCaseMock.result = scenario.given.characterResult

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharacterUseCaseMock.executeCallCount == 1)
        #expect(getCharacterUseCaseMock.lastRequestedIdentifier == identifier)
        #expect(trackerMock.retryButtonTappedCallCount == 1)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.loadErrorDescriptions == scenario.expected.loadErrorDescriptions)
    }

    // MARK: - didTapOnEpisodes

    @Test("didTapOnEpisodes navigates to episodes and tracks event")
    func didTapOnEpisodes() {
        // When
        sut.didTapOnEpisodes()

        // Then
        #expect(navigatorMock.navigateToEpisodesCallCount == 1)
        #expect(navigatorMock.lastNavigateToEpisodesCharacterIdentifier == identifier)
        #expect(trackerMock.episodesButtonTappedIdentifiers == [identifier])
    }

    // MARK: - didPullToRefresh

    @Test("didPullToRefresh produces expected outcome per scenario", arguments: DidPullToRefreshScenario.all)
    func didPullToRefresh(scenario: DidPullToRefreshScenario) async {
        // Given
        await givenLoadedState()
        refreshCharacterUseCaseMock.result = scenario.given.characterResult
        let initialRefreshID = sut.imageRefreshID

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharacterUseCaseMock.executeCallCount == 1)
        #expect(refreshCharacterUseCaseMock.lastRequestedIdentifier == identifier)
        #expect(trackerMock.pullToRefreshTriggeredCallCount == 1)
        #expect(sut.state == scenario.expected.state)
        #expect(imageLoaderMock.removeCachedImageCallCount == scenario.expected.removeCachedImageCallCount)
        #expect((sut.imageRefreshID != initialRefreshID) == scenario.expected.imageRefreshIDChanged)
        #expect(trackerMock.refreshErrorDescriptions == scenario.expected.refreshErrorDescriptions)
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

    // MARK: - Helpers

    private func givenErrorState() async {
        getCharacterUseCaseMock.result = .failure(.loadFailed())
        await sut.didAppear()
        getCharacterUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenLoadedState() async {
        getCharacterUseCaseMock.result = .success(.stub())
        await sut.didAppear()
        getCharacterUseCaseMock.reset()
        trackerMock.reset()
    }
}

// MARK: - Test Helpers

extension CharacterDetailViewModelTests {
    nonisolated struct DidAppearScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let characterResult: Result<Character, CharacterError>
        }

        struct Expected: Sendable {
            let state: CharacterDetailViewState
            let loadErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidAppearScenario] = [
            DidAppearScenario(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(characterResult: .success(.stub())),
                expected: Expected(state: .loaded(.stub()), loadErrorDescriptions: [])
            ),
            DidAppearScenario(
                testDescription: "On failure sets error state and tracks load error",
                given: Given(characterResult: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    loadErrorDescriptions: [CharacterError.loadFailed().debugDescription]
                )
            )
        ]
    }

    nonisolated struct DidTapOnRetryButtonScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let characterResult: Result<Character, CharacterError>
        }

        struct Expected: Sendable {
            let state: CharacterDetailViewState
            let loadErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidTapOnRetryButtonScenario] = [
            DidTapOnRetryButtonScenario(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(characterResult: .success(.stub())),
                expected: Expected(state: .loaded(.stub()), loadErrorDescriptions: [])
            ),
            DidTapOnRetryButtonScenario(
                testDescription: "On failure sets error state and tracks load error",
                given: Given(characterResult: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    loadErrorDescriptions: [CharacterError.loadFailed().debugDescription]
                )
            )
        ]
    }

    nonisolated struct DidPullToRefreshScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let characterResult: Result<Character, CharacterError>
        }

        struct Expected: Sendable {
            let state: CharacterDetailViewState
            let removeCachedImageCallCount: Int
            let imageRefreshIDChanged: Bool
            let refreshErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidPullToRefreshScenario] = [
            DidPullToRefreshScenario(
                testDescription: "On success with image URL invalidates cache and updates refresh ID",
                given: Given(characterResult: .success(.stub(imageURL: URL(string: "https://example.com/avatar.jpeg")))),
                expected: Expected(
                    state: .loaded(.stub(imageURL: URL(string: "https://example.com/avatar.jpeg"))),
                    removeCachedImageCallCount: 1,
                    imageRefreshIDChanged: true,
                    refreshErrorDescriptions: []
                )
            ),
            DidPullToRefreshScenario(
                testDescription: "On success without image URL skips cache invalidation",
                given: Given(characterResult: .success(.stub(imageURL: nil))),
                expected: Expected(
                    state: .loaded(.stub(imageURL: nil)),
                    removeCachedImageCallCount: 0,
                    imageRefreshIDChanged: false,
                    refreshErrorDescriptions: []
                )
            ),
            DidPullToRefreshScenario(
                testDescription: "On failure sets error state and tracks refresh error",
                given: Given(characterResult: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    removeCachedImageCallCount: 0,
                    imageRefreshIDChanged: false,
                    refreshErrorDescriptions: [CharacterError.loadFailed().debugDescription]
                )
            )
        ]
    }
}
