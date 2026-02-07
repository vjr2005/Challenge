import Foundation

protocol RefreshCharacterUseCaseContract: Sendable {
	func execute(identifier: Int) async throws(CharacterError) -> Character
}

struct RefreshCharacterUseCase: RefreshCharacterUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(identifier: Int) async throws(CharacterError) -> Character {
		try await repository.getCharacter(identifier: identifier, cachePolicy: .remoteFirst)
	}
}
