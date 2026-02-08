import Foundation

protocol RecentSearchesRepositoryContract: Sendable {
	func getRecentSearches() -> [String]
	func saveSearch(_ query: String)
	func deleteSearch(_ query: String)
}
