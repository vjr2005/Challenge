import Foundation

@Observable
final class CharacterDetailViewModel: CharacterDetailViewModelContract {
    private(set) var state: CharacterDetailViewState = .idle

    private let identifier: Int
    private let getCharacterUseCase: GetCharacterUseCaseContract
    private let refreshCharacterUseCase: RefreshCharacterUseCaseContract
    private let navigator: CharacterDetailNavigatorContract
    private let tracker: CharacterDetailTrackerContract

    init(
        identifier: Int,
        getCharacterUseCase: GetCharacterUseCaseContract,
        refreshCharacterUseCase: RefreshCharacterUseCaseContract,
        navigator: CharacterDetailNavigatorContract,
        tracker: CharacterDetailTrackerContract
    ) {
        self.identifier = identifier
        self.getCharacterUseCase = getCharacterUseCase
        self.refreshCharacterUseCase = refreshCharacterUseCase
        self.navigator = navigator
        self.tracker = tracker
    }

    func didAppear() async {
        tracker.trackScreenViewed(identifier: identifier)
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

    func didTapOnBack() {
        tracker.trackBackButtonTapped()
        navigator.goBack()
    }

    func didTapOnEpisodes() {
        tracker.trackEpisodesButtonTapped(identifier: identifier)
        navigator.navigateToEpisodes(characterIdentifier: identifier)
    }
}

// MARK: - Private

private extension CharacterDetailViewModel {
    func load() async {
        state = .loading
        do {
            let character = try await getCharacterUseCase.execute(identifier: identifier)
            state = .loaded(character)
        } catch {
            tracker.trackLoadError(description: error.debugDescription)
            state = .error(error)
        }
    }

    func refresh() async {
        do {
            let character = try await refreshCharacterUseCase.execute(identifier: identifier)
            state = .loaded(character)
        } catch {
            tracker.trackRefreshError(description: error.debugDescription)
            state = .error(error)
        }
    }
}
