import Foundation

@Observable
final class CharacterDetailViewModel: CharacterDetailViewModelContract {
    private(set) var state: CharacterDetailViewState = .idle

    private let identifier: Int
    private let getCharacterUseCase: GetCharacterUseCaseContract
    private let refreshCharacterUseCase: RefreshCharacterUseCaseContract
    private let navigator: CharacterDetailNavigatorContract

    init(
        identifier: Int,
        getCharacterUseCase: GetCharacterUseCaseContract,
        refreshCharacterUseCase: RefreshCharacterUseCaseContract,
        navigator: CharacterDetailNavigatorContract
    ) {
        self.identifier = identifier
        self.getCharacterUseCase = getCharacterUseCase
        self.refreshCharacterUseCase = refreshCharacterUseCase
        self.navigator = navigator
    }

    func load() async {
        state = .loading
        do {
            let character = try await getCharacterUseCase.execute(identifier: identifier)
            state = .loaded(character)
        } catch {
            state = .error(error)
        }
    }

    func refresh() async {
        do {
            let character = try await refreshCharacterUseCase.execute(identifier: identifier)
            state = .loaded(character)
        } catch {
            state = .error(error)
        }
    }

    func didTapOnBack() {
        navigator.goBack()
    }
}
