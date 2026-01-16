import Foundation

/// Contract for getting a paginated list of characters.
protocol GetCharactersUseCaseContract: Sendable {
	func execute(page: Int) async throws -> CharactersPage
}

/// UseCase that retrieves a paginated list of characters from the repository.
struct GetCharactersUseCase: GetCharactersUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int) async throws -> CharactersPage {
		try await repository.getCharacters(page: page)
	}
}
