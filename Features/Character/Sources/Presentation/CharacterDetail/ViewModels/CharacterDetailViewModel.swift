import Foundation

@Observable
final class CharacterDetailViewModel: CharacterDetailViewModelContract {
    private(set) var state: CharacterDetailViewState = .idle

    private let identifier: Int
    private let getCharacterDetailUseCase: GetCharacterDetailUseCaseContract
    private let refreshCharacterDetailUseCase: RefreshCharacterDetailUseCaseContract
    private let navigator: CharacterDetailNavigatorContract

    init(
        identifier: Int,
        getCharacterDetailUseCase: GetCharacterDetailUseCaseContract,
        refreshCharacterDetailUseCase: RefreshCharacterDetailUseCaseContract,
        navigator: CharacterDetailNavigatorContract
    ) {
        self.identifier = identifier
        self.getCharacterDetailUseCase = getCharacterDetailUseCase
        self.refreshCharacterDetailUseCase = refreshCharacterDetailUseCase
        self.navigator = navigator
    }

    func loadIfNeeded() async {
        switch state {
        case .idle, .error:
            await load()
        case .loading, .loaded:
            break
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

    func didTapOnBack() {
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
}
