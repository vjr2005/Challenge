protocol RecentSearchesLocalDataSourceContract: Actor {
	func getRecentSearches() -> [String]
	func saveSearch(_ query: String)
	func deleteSearch(_ query: String)
}
