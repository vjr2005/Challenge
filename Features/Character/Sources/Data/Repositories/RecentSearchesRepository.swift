import Foundation

nonisolated struct RecentSearchesRepository: RecentSearchesRepositoryContract {
	private let localDataSource: any RecentSearchesLocalDataSourceContract

	init(localDataSource: any RecentSearchesLocalDataSourceContract) {
		self.localDataSource = localDataSource
	}

	@concurrent func getRecentSearches() async -> [String] {
		await localDataSource.getRecentSearches()
	}

	@concurrent func saveSearch(_ query: String) async {
		await localDataSource.saveSearch(query)
	}

	@concurrent func deleteSearch(_ query: String) async {
		await localDataSource.deleteSearch(query)
	}
}
