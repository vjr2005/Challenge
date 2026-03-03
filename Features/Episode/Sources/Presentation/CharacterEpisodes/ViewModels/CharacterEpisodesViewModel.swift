import Foundation

@Observable
final class CharacterEpisodesViewModel: CharacterEpisodesViewModelContract {
	// MARK: - Properties

	private(set) var state: CharacterEpisodesViewState = .idle

	// MARK: - Dependencies

	private let characterIdentifier: Int
	private let getCharacterEpisodesUseCase: any GetCharacterEpisodesUseCaseContract
	private let refreshCharacterEpisodesUseCase: any RefreshCharacterEpisodesUseCaseContract
	private let navigator: any CharacterEpisodesNavigatorContract
	private let tracker: any CharacterEpisodesTrackerContract

	// MARK: - Init

	init(
		characterIdentifier: Int,
		getCharacterEpisodesUseCase: any GetCharacterEpisodesUseCaseContract,
		refreshCharacterEpisodesUseCase: any RefreshCharacterEpisodesUseCaseContract,
		navigator: any CharacterEpisodesNavigatorContract,
		tracker: any CharacterEpisodesTrackerContract
	) {
		self.characterIdentifier = characterIdentifier
		self.getCharacterEpisodesUseCase = getCharacterEpisodesUseCase
		self.refreshCharacterEpisodesUseCase = refreshCharacterEpisodesUseCase
		self.navigator = navigator
		self.tracker = tracker
	}

	// MARK: - CharacterEpisodesViewModelContract

	func didAppear() async {
		tracker.trackScreenViewed(characterIdentifier: characterIdentifier)
		await load()
	}

	func didTapOnRetryButton() async {
		tracker.trackRetryButtonTapped()
		await load()
	}

	func didPullToRefresh() async {
		tracker.trackPullToRefreshTriggered()
		await refresh()
	}

	func didTapOnCharacter(identifier: Int) {
		tracker.trackCharacterAvatarTapped(identifier: identifier)
		navigator.navigateToCharacterDetail(identifier: identifier)
	}
}

// MARK: - Private

private extension CharacterEpisodesViewModel {
	func load() async {
		state = .loading
		do {
			let result = try await getCharacterEpisodesUseCase.execute(characterIdentifier: characterIdentifier)
			state = .loaded(result)
		} catch {
			tracker.trackLoadError(description: error.debugDescription)
			state = .error(error)
		}
	}

	func refresh() async {
		do {
			let result = try await refreshCharacterEpisodesUseCase.execute(characterIdentifier: characterIdentifier)
			state = .loaded(result)
		} catch {
			tracker.trackRefreshError(description: error.debugDescription)
			state = .error(error)
		}
	}
}
