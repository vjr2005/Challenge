import Foundation

protocol RecentSearchesRepositoryContract: Sendable {
	func getRecentSearches() async -> [String]
	func saveSearch(_ query: String) async
	func deleteSearch(_ query: String) async
}
