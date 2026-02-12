import Foundation

struct RecentSearchesRepository: RecentSearchesRepositoryContract {
	private let localDataSource: RecentSearchesLocalDataSourceContract

	init(localDataSource: RecentSearchesLocalDataSourceContract) {
		self.localDataSource = localDataSource
	}

	func getRecentSearches() async -> [String] {
		await localDataSource.getRecentSearches()
	}

	func saveSearch(_ query: String) async {
		await localDataSource.saveSearch(query)
	}

	func deleteSearch(_ query: String) async {
		await localDataSource.deleteSearch(query)
	}
}
