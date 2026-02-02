import Foundation

protocol RefreshCharacterDetailUseCaseContract: Sendable {
	func execute(identifier: Int) async throws(CharacterError) -> Character
}

struct RefreshCharacterDetailUseCase: RefreshCharacterDetailUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute(identifier: Int) async throws(CharacterError) -> Character {
		try await repository.getCharacterDetail(identifier: identifier, cachePolicy: .remoteFirst)
	}
}
