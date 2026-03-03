import Foundation

protocol DeleteRecentSearchUseCaseContract: Sendable {
	func execute(query: String) async
}

struct DeleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract {
	private let repository: any RecentSearchesRepositoryContract

	init(repository: any RecentSearchesRepositoryContract) {
		self.repository = repository
	}

	func execute(query: String) async {
		await repository.deleteSearch(query)
	}
}
