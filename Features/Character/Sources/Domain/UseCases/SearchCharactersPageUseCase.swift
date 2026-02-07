import Foundation

protocol SearchCharactersPageUseCaseContract: Sendable {
	func execute(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage
}

struct SearchCharactersPageUseCase: SearchCharactersPageUseCaseContract {
	private let repository: CharactersPageRepositoryContract

	init(repository: CharactersPageRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
		try await repository.searchCharactersPage(page: page, filter: filter)
	}
}
