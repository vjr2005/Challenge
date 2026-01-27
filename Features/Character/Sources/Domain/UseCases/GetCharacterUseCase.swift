import Foundation

protocol GetCharacterUseCaseContract: Sendable {
	func execute(identifier: Int) async throws -> Character
}

struct GetCharacterUseCase: GetCharacterUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(identifier: Int) async throws -> Character {
		try await repository.getCharacter(identifier: identifier)
	}
}
