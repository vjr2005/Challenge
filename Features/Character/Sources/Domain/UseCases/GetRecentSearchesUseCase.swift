import Foundation

protocol GetRecentSearchesUseCaseContract: Sendable {
	func execute() async -> [String]
}

struct GetRecentSearchesUseCase: GetRecentSearchesUseCaseContract {
	private let repository: RecentSearchesRepositoryContract

	init(repository: RecentSearchesRepositoryContract) {
		self.repository = repository
	}

	func execute() async -> [String] {
		await repository.getRecentSearches()
	}
}
