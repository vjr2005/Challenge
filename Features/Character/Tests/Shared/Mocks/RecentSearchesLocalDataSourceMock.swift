import Foundation

@testable import ChallengeCharacter

actor RecentSearchesLocalDataSourceMock: RecentSearchesLocalDataSourceContract {
	// MARK: - Configurable Returns

	private(set) var searches: [String] = []

	func setSearches(_ searches: [String]) {
		self.searches = searches
	}

	// MARK: - Call Tracking

	private(set) var getRecentSearchesCallCount = 0
	private(set) var saveSearchCallCount = 0
	private(set) var lastSavedQuery: String?
	private(set) var deleteSearchCallCount = 0
	private(set) var lastDeletedQuery: String?

	// MARK: - RecentSearchesLocalDataSourceContract

	func getRecentSearches() -> [String] {
		getRecentSearchesCallCount += 1
		return searches
	}

	func saveSearch(_ query: String) {
		saveSearchCallCount += 1
		lastSavedQuery = query
	}

	func deleteSearch(_ query: String) {
		deleteSearchCallCount += 1
		lastDeletedQuery = query
	}
}
