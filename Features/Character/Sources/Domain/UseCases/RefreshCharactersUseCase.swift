import Foundation

protocol RefreshCharactersUseCaseContract: Sendable {
	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage
}

struct RefreshCharactersUseCase: RefreshCharactersUseCaseContract {
	private let repository: CharactersPageRepositoryContract

	init(repository: CharactersPageRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage {
		try await repository.getCharacters(page: page, cachePolicy: .remoteFirst)
	}
}
