import Foundation

protocol SaveRecentSearchUseCaseContract: Sendable {
	func execute(query: String) async
}

struct SaveRecentSearchUseCase: SaveRecentSearchUseCaseContract {
	private let repository: any RecentSearchesRepositoryContract

	init(repository: any RecentSearchesRepositoryContract) {
		self.repository = repository
	}

	func execute(query: String) async {
		await repository.saveSearch(query)
	}
}
