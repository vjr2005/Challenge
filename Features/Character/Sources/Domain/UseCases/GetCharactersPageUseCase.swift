import Foundation

protocol GetCharactersPageUseCaseContract: Sendable {
	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage
}

struct GetCharactersPageUseCase: GetCharactersPageUseCaseContract {
	private let repository: CharactersPageRepositoryContract

	init(repository: CharactersPageRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage {
		try await repository.getCharactersPage(page: page, cachePolicy: .localFirst)
	}
}
