import Foundation

protocol GetCharactersUseCaseContract: Sendable {
	func execute(page: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> CharactersPage
}

// MARK: - Default Parameters

extension GetCharactersUseCaseContract {
	func execute(page: Int) async throws(CharacterError) -> CharactersPage {
		try await execute(page: page, cachePolicy: .localFirst)
	}
}

struct GetCharactersUseCase: GetCharactersUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> CharactersPage {
		try await repository.getCharacters(page: page, cachePolicy: cachePolicy)
	}
}
