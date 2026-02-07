import Foundation

protocol SearchCharactersUseCaseContract: Sendable {
	func execute(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage
}

struct SearchCharactersUseCase: SearchCharactersUseCaseContract {
	private let repository: CharactersPageRepositoryContract

	init(repository: CharactersPageRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
		try await repository.searchCharacters(page: page, filter: filter)
	}
}
