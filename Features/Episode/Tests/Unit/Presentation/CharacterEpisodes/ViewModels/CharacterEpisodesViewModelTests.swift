import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct CharacterEpisodesViewModelTests {
	// MARK: - Properties

	private let characterIdentifier = 1
	private let getCharacterEpisodesUseCaseMock = GetCharacterEpisodesUseCaseMock()
	private let refreshCharacterEpisodesUseCaseMock = RefreshCharacterEpisodesUseCaseMock()
	private let navigatorMock = CharacterEpisodesNavigatorMock()
	private let trackerMock = CharacterEpisodesTrackerMock()
	private let sut: CharacterEpisodesViewModel

	// MARK: - Initialization

	init() {
		sut = CharacterEpisodesViewModel(
			characterIdentifier: characterIdentifier,
			getCharacterEpisodesUseCase: getCharacterEpisodesUseCaseMock,
			refreshCharacterEpisodesUseCase: refreshCharacterEpisodesUseCaseMock,
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
		getCharacterEpisodesUseCaseMock.result = scenario.given.characterWithEpisodesResult

		// When
		await sut.didAppear()

		// Then
		#expect(getCharacterEpisodesUseCaseMock.executeCallCount == 1)
		#expect(getCharacterEpisodesUseCaseMock.lastRequestedCharacterIdentifier == characterIdentifier)
		#expect(trackerMock.screenViewedCharacterIdentifiers == [characterIdentifier])
		#expect(sut.state == scenario.expected.state)
		#expect(trackerMock.loadErrorDescriptions == scenario.expected.loadErrorDescriptions)
	}

	// MARK: - didTapOnRetryButton

	@Test("didTapOnRetryButton produces expected outcome per scenario", arguments: DidTapOnRetryButtonScenario.all)
	func didTapOnRetryButton(scenario: DidTapOnRetryButtonScenario) async {
		// Given
		await givenErrorState()
		getCharacterEpisodesUseCaseMock.result = scenario.given.characterWithEpisodesResult

		// When
		await sut.didTapOnRetryButton()

		// Then
		#expect(getCharacterEpisodesUseCaseMock.executeCallCount == 1)
		#expect(getCharacterEpisodesUseCaseMock.lastRequestedCharacterIdentifier == characterIdentifier)
		#expect(trackerMock.retryButtonTappedCallCount == 1)
		#expect(sut.state == scenario.expected.state)
		#expect(trackerMock.loadErrorDescriptions == scenario.expected.loadErrorDescriptions)
	}

	// MARK: - didPullToRefresh

	@Test("didPullToRefresh produces expected outcome per scenario", arguments: DidPullToRefreshScenario.all)
	func didPullToRefresh(scenario: DidPullToRefreshScenario) async {
		// Given
		await givenLoadedState()
		refreshCharacterEpisodesUseCaseMock.result = scenario.given.characterWithEpisodesResult

		// When
		await sut.didPullToRefresh()

		// Then
		#expect(refreshCharacterEpisodesUseCaseMock.executeCallCount == 1)
		#expect(refreshCharacterEpisodesUseCaseMock.lastRequestedCharacterIdentifier == characterIdentifier)
		#expect(trackerMock.pullToRefreshTriggeredCallCount == 1)
		#expect(sut.state == scenario.expected.state)
		#expect(trackerMock.refreshErrorDescriptions == scenario.expected.refreshErrorDescriptions)
	}

	@Test("didPullToRefresh keeps loaded state visible during network request")
	func didPullToRefreshKeepsLoadedStateDuringRequest() async {
		// Given
		let loadedData = EpisodeCharacterWithEpisodes.stub()
		getCharacterEpisodesUseCaseMock.result = .success(loadedData)
		await sut.didAppear()
		refreshCharacterEpisodesUseCaseMock.result = .success(.stub())

		var statesDuringRefresh: [CharacterEpisodesViewState] = []
		refreshCharacterEpisodesUseCaseMock.onExecute = { [weak sut] in
			guard let sut else { return }
			statesDuringRefresh.append(sut.state)
		}

		// When
		await sut.didPullToRefresh()

		// Then
		#expect(statesDuringRefresh.count == 1)
		#expect(statesDuringRefresh.first == .loaded(loadedData))
	}

	// MARK: - didTapOnCharacter

	@Test("didTapOnCharacter navigates to character detail and tracks event")
	func didTapOnCharacter() {
		// When
		sut.didTapOnCharacter(identifier: 42)

		// Then
		#expect(navigatorMock.navigateToCharacterDetailCallCount == 1)
		#expect(navigatorMock.lastNavigateToCharacterDetailIdentifier == 42)
		#expect(trackerMock.characterAvatarTappedIdentifiers == [42])
	}

	// MARK: - Helpers

	private func givenErrorState() async {
		getCharacterEpisodesUseCaseMock.result = .failure(.loadFailed())
		await sut.didAppear()
		getCharacterEpisodesUseCaseMock.reset()
		trackerMock.reset()
	}

	private func givenLoadedState() async {
		getCharacterEpisodesUseCaseMock.result = .success(.stub())
		await sut.didAppear()
		getCharacterEpisodesUseCaseMock.reset()
		trackerMock.reset()
	}
}

// MARK: - Test Helpers

extension CharacterEpisodesViewModelTests {
	nonisolated struct DidAppearScenario: Sendable, CustomTestStringConvertible {
		struct Given: Sendable {
			let characterWithEpisodesResult: Result<EpisodeCharacterWithEpisodes, EpisodeError>
		}

		struct Expected: Sendable {
			let state: CharacterEpisodesViewState
			let loadErrorDescriptions: [String]
		}

		let testDescription: String
		let given: Given
		let expected: Expected

		static let all: [DidAppearScenario] = [
			DidAppearScenario(
				testDescription: "On success sets loaded state without tracking error",
				given: Given(characterWithEpisodesResult: .success(.stub())),
				expected: Expected(state: .loaded(.stub()), loadErrorDescriptions: [])
			),
			DidAppearScenario(
				testDescription: "On failure sets error state and tracks load error",
				given: Given(characterWithEpisodesResult: .failure(.loadFailed())),
				expected: Expected(
					state: .error(.loadFailed()),
					loadErrorDescriptions: [EpisodeError.loadFailed().debugDescription]
				)
			),
		]
	}

	nonisolated struct DidTapOnRetryButtonScenario: Sendable, CustomTestStringConvertible {
		struct Given: Sendable {
			let characterWithEpisodesResult: Result<EpisodeCharacterWithEpisodes, EpisodeError>
		}

		struct Expected: Sendable {
			let state: CharacterEpisodesViewState
			let loadErrorDescriptions: [String]
		}

		let testDescription: String
		let given: Given
		let expected: Expected

		static let all: [DidTapOnRetryButtonScenario] = [
			DidTapOnRetryButtonScenario(
				testDescription: "On success sets loaded state without tracking error",
				given: Given(characterWithEpisodesResult: .success(.stub())),
				expected: Expected(state: .loaded(.stub()), loadErrorDescriptions: [])
			),
			DidTapOnRetryButtonScenario(
				testDescription: "On failure sets error state and tracks load error",
				given: Given(characterWithEpisodesResult: .failure(.loadFailed())),
				expected: Expected(
					state: .error(.loadFailed()),
					loadErrorDescriptions: [EpisodeError.loadFailed().debugDescription]
				)
			),
		]
	}

	nonisolated struct DidPullToRefreshScenario: Sendable, CustomTestStringConvertible {
		struct Given: Sendable {
			let characterWithEpisodesResult: Result<EpisodeCharacterWithEpisodes, EpisodeError>
		}

		struct Expected: Sendable {
			let state: CharacterEpisodesViewState
			let refreshErrorDescriptions: [String]
		}

		let testDescription: String
		let given: Given
		let expected: Expected

		static let all: [DidPullToRefreshScenario] = [
			DidPullToRefreshScenario(
				testDescription: "On success sets loaded state without tracking error",
				given: Given(characterWithEpisodesResult: .success(.stub())),
				expected: Expected(state: .loaded(.stub()), refreshErrorDescriptions: [])
			),
			DidPullToRefreshScenario(
				testDescription: "On failure sets error state and tracks refresh error",
				given: Given(characterWithEpisodesResult: .failure(.loadFailed())),
				expected: Expected(
					state: .error(.loadFailed()),
					refreshErrorDescriptions: [EpisodeError.loadFailed().debugDescription]
				)
			),
		]
	}

}
