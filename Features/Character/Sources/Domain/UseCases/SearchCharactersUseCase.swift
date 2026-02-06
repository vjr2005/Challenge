import Foundation

protocol SearchCharactersUseCaseContract: Sendable {
	func execute(page: Int, filter: CharacterFilter) async throws(CharacterError) -> CharactersPage
}

struct SearchCharactersUseCase: SearchCharactersUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int, filter: CharacterFilter) async throws(CharacterError) -> CharactersPage {
		try await repository.searchCharacters(page: page, filter: filter)
	}
}
