import Foundation

protocol GetRecentSearchesUseCaseContract: Sendable {
	func execute() -> [String]
}

struct GetRecentSearchesUseCase: GetRecentSearchesUseCaseContract {
	private let repository: RecentSearchesRepositoryContract

	init(repository: RecentSearchesRepositoryContract) {
		self.repository = repository
	}

	func execute() -> [String] {
		repository.getRecentSearches()
	}
}
