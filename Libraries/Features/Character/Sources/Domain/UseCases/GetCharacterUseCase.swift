import Foundation

/// Contract for getting a character by ID.
protocol GetCharacterUseCaseContract: Sendable {
	func execute(id: Int) async throws -> Character
}

/// UseCase that retrieves a character from the repository.
struct GetCharacterUseCase: GetCharacterUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(id: Int) async throws -> Character {
		try await repository.getCharacter(id: id)
	}
}
