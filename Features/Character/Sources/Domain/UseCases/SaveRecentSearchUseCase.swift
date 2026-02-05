import Foundation

protocol SaveRecentSearchUseCaseContract: Sendable {
	func execute(query: String)
}

struct SaveRecentSearchUseCase: SaveRecentSearchUseCaseContract {
	private let dataSource: RecentSearchesLocalDataSourceContract

	init(dataSource: RecentSearchesLocalDataSourceContract) {
		self.dataSource = dataSource
	}

	func execute(query: String) {
		dataSource.saveSearch(query)
	}
}
