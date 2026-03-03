import Foundation

protocol GetCharacterUseCaseContract: Sendable {
	func execute(identifier: Int) async throws(CharacterError) -> Character
}

struct GetCharacterUseCase: GetCharacterUseCaseContract {
	private let repository: any CharacterRepositoryContract

	init(repository: any CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(identifier: Int) async throws(CharacterError) -> Character {
		try await repository.getCharacter(identifier: identifier, cachePolicy: .localFirst)
	}
}
