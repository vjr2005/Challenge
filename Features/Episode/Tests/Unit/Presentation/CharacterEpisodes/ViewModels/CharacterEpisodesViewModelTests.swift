import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct CharacterEpisodesViewModelTests {
	// MARK: - Properties

	private let getCharacterEpisodesUseCaseMock = GetCharacterEpisodesUseCaseMock()
	private let refreshCharacterEpisodesUseCaseMock = RefreshCharacterEpisodesUseCaseMock()
	private let navigatorMock = CharacterEpisodesNavigatorMock()
	private let trackerMock = CharacterEpisodesTrackerMock()
	private let sut: CharacterEpisodesViewModel

	// MARK: - Init

	init() {
		sut = CharacterEpisodesViewModel(
			characterIdentifier: 1,
			getCharacterEpisodesUseCase: getCharacterEpisodesUseCaseMock,
			refreshCharacterEpisodesUseCase: refreshCharacterEpisodesUseCaseMock,
			navigator: navigatorMock,
			tracker: trackerMock
		)
	}

	// MARK: - Initial State

	@Test("Initial state is idle")
	func initialStateIsIdle() {
		#expect(sut.state == .idle)
	}

	// MARK: - Did Appear

	@Test("didAppear sets loaded state on success")
	func didAppearSetsLoadedOnSuccess() async {
		// Given
		let expected = EpisodeCharacterWithEpisodes.stub()
		getCharacterEpisodesUseCaseMock.result = .success(expected)

		// When
		await sut.didAppear()

		// Then
		#expect(sut.state == .loaded(expected))
	}

	@Test("didAppear sets error state on failure")
	func didAppearSetsErrorOnFailure() async {
		// Given
		getCharacterEpisodesUseCaseMock.result = .failure(.loadFailed())

		// When
		await sut.didAppear()

		// Then
		#expect(sut.state == .error(.loadFailed()))
	}

	@Test("didAppear calls use case with correct character identifier")
	func didAppearCallsUseCaseWithCorrectIdentifier() async {
		// Given
		getCharacterEpisodesUseCaseMock.result = .success(.stub())

		// When
		await sut.didAppear()

		// Then
		#expect(getCharacterEpisodesUseCaseMock.executeCallCount == 1)
		#expect(getCharacterEpisodesUseCaseMock.lastRequestedCharacterIdentifier == 1)
	}

	@Test("didAppear tracks screen viewed with character identifier")
	func didAppearTracksScreenViewed() async {
		// Given
		getCharacterEpisodesUseCaseMock.result = .success(.stub())

		// When
		await sut.didAppear()

		// Then
		#expect(trackerMock.screenViewedCharacterIdentifiers == [1])
	}

	@Test("didAppear tracks load error on failure")
	func didAppearTracksLoadError() async {
		// Given
		getCharacterEpisodesUseCaseMock.result = .failure(.loadFailed())

		// When
		await sut.didAppear()

		// Then
		#expect(trackerMock.loadErrorDescriptions.count == 1)
	}

	// MARK: - Did Tap On Retry Button

	@Test("didTapOnRetryButton retries loading")
	func didTapOnRetryButtonRetriesLoading() async {
		// Given
		getCharacterEpisodesUseCaseMock.result = .failure(.loadFailed())
		await sut.didAppear()

		// When
		getCharacterEpisodesUseCaseMock.result = .success(.stub())
		await sut.didTapOnRetryButton()

		// Then
		#expect(getCharacterEpisodesUseCaseMock.executeCallCount == 2)
	}

	@Test("didTapOnRetryButton sets loaded state on success")
	func didTapOnRetryButtonSetsLoadedOnSuccess() async {
		// Given
		getCharacterEpisodesUseCaseMock.result = .failure(.loadFailed())
		await sut.didAppear()
		let expected = EpisodeCharacterWithEpisodes.stub()
		getCharacterEpisodesUseCaseMock.result = .success(expected)

		// When
		await sut.didTapOnRetryButton()

		// Then
		#expect(sut.state == .loaded(expected))
	}

	@Test("didTapOnRetryButton tracks retry button tapped")
	func didTapOnRetryButtonTracksRetry() async {
		// Given
		getCharacterEpisodesUseCaseMock.result = .success(.stub())

		// When
		await sut.didTapOnRetryButton()

		// Then
		#expect(trackerMock.retryButtonTappedCallCount == 1)
	}

	// MARK: - Did Pull To Refresh

	@Test("didPullToRefresh calls refresh use case")
	func didPullToRefreshCallsRefreshUseCase() async {
		// Given
		refreshCharacterEpisodesUseCaseMock.result = .success(.stub())

		// When
		await sut.didPullToRefresh()

		// Then
		#expect(refreshCharacterEpisodesUseCaseMock.executeCallCount == 1)
	}

	@Test("didPullToRefresh calls refresh use case with correct character identifier")
	func didPullToRefreshCallsRefreshWithCorrectIdentifier() async {
		// Given
		refreshCharacterEpisodesUseCaseMock.result = .success(.stub())

		// When
		await sut.didPullToRefresh()

		// Then
		#expect(refreshCharacterEpisodesUseCaseMock.lastRequestedCharacterIdentifier == 1)
	}

	@Test("didPullToRefresh updates state on success")
	func didPullToRefreshUpdatesState() async {
		// Given
		getCharacterEpisodesUseCaseMock.result = .success(.stub())
		await sut.didAppear()
		let refreshed = EpisodeCharacterWithEpisodes.stub(name: "Refreshed")
		refreshCharacterEpisodesUseCaseMock.result = .success(refreshed)

		// When
		await sut.didPullToRefresh()

		// Then
		#expect(sut.state == .loaded(refreshed))
	}

	@Test("didPullToRefresh sets error state on failure")
	func didPullToRefreshSetsErrorOnFailure() async {
		// Given
		refreshCharacterEpisodesUseCaseMock.result = .failure(.loadFailed())

		// When
		await sut.didPullToRefresh()

		// Then
		#expect(sut.state == .error(.loadFailed()))
	}

	@Test("didPullToRefresh tracks pull to refresh triggered")
	func didPullToRefreshTracksPullToRefresh() async {
		// Given
		refreshCharacterEpisodesUseCaseMock.result = .success(.stub())

		// When
		await sut.didPullToRefresh()

		// Then
		#expect(trackerMock.pullToRefreshTriggeredCallCount == 1)
	}

	@Test("didPullToRefresh tracks refresh error on failure")
	func didPullToRefreshTracksRefreshError() async {
		// Given
		refreshCharacterEpisodesUseCaseMock.result = .failure(.loadFailed())

		// When
		await sut.didPullToRefresh()

		// Then
		#expect(trackerMock.refreshErrorDescriptions.count == 1)
	}

	// MARK: - Did Tap On Character

	@Test("didTapOnCharacter navigates to character detail")
	func didTapOnCharacterNavigatesToCharacterDetail() {
		// When
		sut.didTapOnCharacter(identifier: 42)

		// Then
		#expect(navigatorMock.navigateToCharacterDetailCallCount == 1)
		#expect(navigatorMock.lastNavigateToCharacterDetailIdentifier == 42)
	}

	@Test("didTapOnCharacter tracks character avatar tapped")
	func didTapOnCharacterTracksCharacterAvatarTapped() {
		// When
		sut.didTapOnCharacter(identifier: 42)

		// Then
		#expect(trackerMock.characterAvatarTappedIdentifiers == [42])
	}
}
