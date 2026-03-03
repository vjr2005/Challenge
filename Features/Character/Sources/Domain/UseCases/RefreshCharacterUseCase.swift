import Foundation

protocol RefreshCharacterUseCaseContract: Sendable {
	func execute(identifier: Int) async throws(CharacterError) -> Character
}

struct RefreshCharacterUseCase: RefreshCharacterUseCaseContract {
	private let repository: any CharacterRepositoryContract

	init(repository: any CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(identifier: Int) async throws(CharacterError) -> Character {
		try await repository.getCharacter(identifier: identifier, cachePolicy: .remoteFirst)
	}
}
