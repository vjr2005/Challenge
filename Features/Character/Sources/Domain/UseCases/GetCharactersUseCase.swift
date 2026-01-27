import Foundation

protocol GetCharactersUseCaseContract: Sendable {
	func execute(page: Int) async throws -> CharactersPage
}

struct GetCharactersUseCase: GetCharactersUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int) async throws -> CharactersPage {
		try await repository.getCharacters(page: page)
	}
}
