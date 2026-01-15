import SwiftUI

/// ViewModel that manages Character state and coordinates with UseCases.
@MainActor
@Observable
final class CharacterViewModel {
	private(set) var state: CharacterViewState = .idle

	private let getCharacterUseCase: GetCharacterUseCaseContract
	private let router: CharacterRouter?

	init(
		getCharacterUseCase: GetCharacterUseCaseContract,
		router: CharacterRouter? = nil
	) {
		self.getCharacterUseCase = getCharacterUseCase
		self.router = router
	}

	func load(id: Int) async {
		state = .loading
		do {
			let character = try await getCharacterUseCase.execute(id: id)
			state = .loaded(character)
		} catch {
			state = .error(error)
		}
	}
}
