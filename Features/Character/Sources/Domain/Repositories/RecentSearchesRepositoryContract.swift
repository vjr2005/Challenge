import Foundation

nonisolated protocol RecentSearchesRepositoryContract: Sendable {
	@concurrent func getRecentSearches() async -> [String]
	@concurrent func saveSearch(_ query: String) async
	@concurrent func deleteSearch(_ query: String) async
}
