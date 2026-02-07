import Foundation

protocol GetCharactersUseCaseContract: Sendable {
	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage
}

struct GetCharactersUseCase: GetCharactersUseCaseContract {
	private let repository: CharactersPageRepositoryContract

	init(repository: CharactersPageRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage {
		try await repository.getCharacters(page: page, cachePolicy: .localFirst)
	}
}
