import Foundation

protocol DeleteRecentSearchUseCaseContract: Sendable {
	func execute(query: String)
}

struct DeleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract {
	private let dataSource: RecentSearchesLocalDataSourceContract

	init(dataSource: RecentSearchesLocalDataSourceContract) {
		self.dataSource = dataSource
	}

	func execute(query: String) {
		dataSource.deleteSearch(query)
	}
}
