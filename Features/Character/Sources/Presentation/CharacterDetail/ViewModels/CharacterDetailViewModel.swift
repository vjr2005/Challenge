import ChallengeCore
import Foundation

@Observable
final class CharacterDetailViewModel: CharacterDetailViewModelContract {
    private(set) var state: CharacterDetailViewState = .idle

    private let identifier: Int
    private let getCharacterDetailUseCase: GetCharacterDetailUseCaseContract
    private let refreshCharacterDetailUseCase: RefreshCharacterDetailUseCaseContract
    private let navigator: CharacterDetailNavigatorContract
    private let tracker: CharacterDetailTrackerContract

    init(
        identifier: Int,
        getCharacterDetailUseCase: GetCharacterDetailUseCaseContract,
        refreshCharacterDetailUseCase: RefreshCharacterDetailUseCaseContract,
        navigator: CharacterDetailNavigatorContract,
        tracker: CharacterDetailTrackerContract
    ) {
        self.identifier = identifier
        self.getCharacterDetailUseCase = getCharacterDetailUseCase
        self.refreshCharacterDetailUseCase = refreshCharacterDetailUseCase
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
}

// MARK: - Private

private extension CharacterDetailViewModel {
    func load() async {
        state = .loading
        do {
            let character = try await getCharacterDetailUseCase.execute(identifier: identifier)
            state = .loaded(character)
        } catch {
            state = .error(error)
        }
    }

    func refresh() async {
        do {
            let character = try await refreshCharacterDetailUseCase.execute(identifier: identifier)
            state = .loaded(character)
        } catch {
            state = .error(error)
        }
    }
}
