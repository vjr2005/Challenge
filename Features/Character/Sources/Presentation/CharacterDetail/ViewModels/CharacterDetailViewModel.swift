import ChallengeCore
import Foundation

@Observable
final class CharacterDetailViewModel: CharacterDetailViewModelContract {
    private(set) var state: CharacterDetailViewState = .idle
    private(set) var imageRefreshID = UUID()

    private let identifier: Int
    private let getCharacterUseCase: GetCharacterUseCaseContract
    private let refreshCharacterUseCase: RefreshCharacterUseCaseContract
    private let imageLoader: any ImageLoaderContract
    private let navigator: CharacterDetailNavigatorContract
    private let tracker: CharacterDetailTrackerContract

    init(
        identifier: Int,
        getCharacterUseCase: GetCharacterUseCaseContract,
        refreshCharacterUseCase: RefreshCharacterUseCaseContract,
        imageLoader: any ImageLoaderContract,
        navigator: CharacterDetailNavigatorContract,
        tracker: CharacterDetailTrackerContract
    ) {
        self.identifier = identifier
        self.getCharacterUseCase = getCharacterUseCase
        self.refreshCharacterUseCase = refreshCharacterUseCase
        self.imageLoader = imageLoader
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
            if let imageURL = character.imageURL {
                await imageLoader.removeCachedImage(for: imageURL)
                imageRefreshID = UUID()
            }
            state = .loaded(character)
        } catch {
            tracker.trackRefreshError(description: error.debugDescription)
            state = .error(error)
        }
    }
}
