import Foundation

protocol GetRecentSearchesUseCaseContract: Sendable {
	func execute() -> [String]
}

struct GetRecentSearchesUseCase: GetRecentSearchesUseCaseContract {
	private let dataSource: RecentSearchesLocalDataSourceContract

	init(dataSource: RecentSearchesLocalDataSourceContract) {
		self.dataSource = dataSource
	}

	func execute() -> [String] {
		dataSource.getRecentSearches()
	}
}
