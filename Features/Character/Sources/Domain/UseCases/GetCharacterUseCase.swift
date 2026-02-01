import Foundation

protocol GetCharacterUseCaseContract: Sendable {
	func execute(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
}

// MARK: - Default Parameters

extension GetCharacterUseCaseContract {
	func execute(identifier: Int) async throws(CharacterError) -> Character {
		try await execute(identifier: identifier, cachePolicy: .localFirst)
	}
}

struct GetCharacterUseCase: GetCharacterUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
		try await repository.getCharacter(identifier: identifier, cachePolicy: cachePolicy)
	}
}
