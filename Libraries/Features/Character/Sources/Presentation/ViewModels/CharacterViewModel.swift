import SwiftUI

/// ViewModel that manages Character state and coordinates with UseCases.
@Observable
final class CharacterViewModel {
	private(set) var state: CharacterViewState = .idle

    private let identifier: Int
	private let getCharacterUseCase: GetCharacterUseCaseContract
	private let router: CharacterRouter?

    init(
        identifier: Int,
        getCharacterUseCase: GetCharacterUseCaseContract,
        router: CharacterRouter? = nil
    ) {
        self.identifier = identifier
        self.getCharacterUseCase = getCharacterUseCase
        self.router = router
    }

	func load(identifier: Int) async {
		state = .loading
		do {
			let character = try await getCharacterUseCase.execute(identifier: identifier)
			state = .loaded(character)
		} catch {
			state = .error(error)
		}
	}
}
