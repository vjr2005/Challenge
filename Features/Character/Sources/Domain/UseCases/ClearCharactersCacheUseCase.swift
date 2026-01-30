import Foundation

protocol ClearCharactersCacheUseCaseContract: Sendable {
	func execute() async
}

struct ClearCharactersCacheUseCase: ClearCharactersCacheUseCaseContract {
	private let repository: CharacterRepositoryContract

	init(repository: CharacterRepositoryContract) {
		self.repository = repository
	}

	func execute() async {
		await repository.clearPagesCache()
	}
}
