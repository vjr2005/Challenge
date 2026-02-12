import Foundation

struct RecentSearchesUserDefaultsDataSource: RecentSearchesLocalDataSourceContract {
	private nonisolated(unsafe) let userDefaults: UserDefaults
	private let key = "recentSearches"
	private let maxCount = 5

	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}

	func getRecentSearches() -> [String] {
		userDefaults.stringArray(forKey: key) ?? []
	}

	func saveSearch(_ query: String) {
		var searches = getRecentSearches()
		searches.removeAll { $0.caseInsensitiveCompare(query) == .orderedSame }
		searches.insert(query, at: 0)
		if searches.count > maxCount {
			searches = Array(searches.prefix(maxCount))
		}
		userDefaults.set(searches, forKey: key)
	}

	func deleteSearch(_ query: String) {
		var searches = getRecentSearches()
		searches.removeAll { $0.caseInsensitiveCompare(query) == .orderedSame }
		userDefaults.set(searches, forKey: key)
	}
}
