import Foundation

protocol RefreshCharactersPageUseCaseContract: Sendable {
	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage
}

struct RefreshCharactersPageUseCase: RefreshCharactersPageUseCaseContract {
	private let repository: CharactersPageRepositoryContract

	init(repository: CharactersPageRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int) async throws(CharactersPageError) -> CharactersPage {
		await repository.clearPagesCache()
		return try await repository.getCharactersPage(page: page, cachePolicy: .remoteFirst)
	}
}
