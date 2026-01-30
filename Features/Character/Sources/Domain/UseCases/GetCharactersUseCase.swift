import Foundation

protocol GetCharactersUseCaseContract: Sendable {
	func execute(page: Int, query: String?) async throws(CharacterError) -> CharactersPage
}

struct GetCharactersUseCase: GetCharactersUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int, query: String?) async throws(CharacterError) -> CharactersPage {
		if let query, !query.isEmpty {
			try await repository.searchCharacters(page: page, query: query)
		} else {
			try await repository.getCharacters(page: page)
		}
	}
}
