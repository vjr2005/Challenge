import Foundation

protocol RefreshCharactersUseCaseContract: Sendable {
	func execute(page: Int) async throws(CharacterError) -> CharactersPage
}

struct RefreshCharactersUseCase: RefreshCharactersUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int) async throws(CharacterError) -> CharactersPage {
		try await repository.getCharacters(page: page, cachePolicy: .remoteFirst)
	}
}
