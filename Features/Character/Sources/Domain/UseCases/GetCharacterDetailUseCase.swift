import Foundation

protocol GetCharacterDetailUseCaseContract: Sendable {
	func execute(identifier: Int) async throws(CharacterError) -> Character
}

struct GetCharacterDetailUseCase: GetCharacterDetailUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(identifier: Int) async throws(CharacterError) -> Character {
		try await repository.getCharacterDetail(identifier: identifier, cachePolicy: .localFirst)
	}
}
