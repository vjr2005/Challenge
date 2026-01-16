import ChallengeCore
import Foundation

/// ViewModel that manages Character state and coordinates with UseCases.
@Observable
final class CharacterDetailViewModel {
    private(set) var state: CharacterDetailViewState = .idle

    private let identifier: Int
    private let getCharacterUseCase: GetCharacterUseCaseContract
    private let router: RouterContract

    init(
        identifier: Int,
        getCharacterUseCase: GetCharacterUseCaseContract,
        router: RouterContract
    ) {
        self.identifier = identifier
        self.getCharacterUseCase = getCharacterUseCase
        self.router = router
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

    func didTapOnBack() {
        router.goBack()
    }
}
