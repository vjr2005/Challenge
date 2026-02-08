import Foundation

struct RecentSearchesRepository: RecentSearchesRepositoryContract {
	private let localDataSource: RecentSearchesLocalDataSourceContract

	init(localDataSource: RecentSearchesLocalDataSourceContract) {
		self.localDataSource = localDataSource
	}

	func getRecentSearches() -> [String] {
		localDataSource.getRecentSearches()
	}

	func saveSearch(_ query: String) {
		localDataSource.saveSearch(query)
	}

	func deleteSearch(_ query: String) {
		localDataSource.deleteSearch(query)
	}
}
