import Foundation

protocol GetRecentSearchesUseCaseContract: Sendable {
	func execute() async -> [String]
}

struct GetRecentSearchesUseCase: GetRecentSearchesUseCaseContract {
	private let repository: any RecentSearchesRepositoryContract

	init(repository: any RecentSearchesRepositoryContract) {
		self.repository = repository
	}

	func execute() async -> [String] {
		await repository.getRecentSearches()
	}
}
