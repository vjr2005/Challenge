import Foundation

protocol SaveRecentSearchUseCaseContract: Sendable {
	func execute(query: String)
}

struct SaveRecentSearchUseCase: SaveRecentSearchUseCaseContract {
	private let repository: RecentSearchesRepositoryContract

	init(repository: RecentSearchesRepositoryContract) {
		self.repository = repository
	}

	func execute(query: String) {
		repository.saveSearch(query)
	}
}
