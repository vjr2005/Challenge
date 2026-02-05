import Foundation

@testable import ChallengeCharacter

final class RecentSearchesLocalDataSourceMock: RecentSearchesLocalDataSourceContract, @unchecked Sendable {
	var searches: [String] = []
	private(set) var getRecentSearchesCallCount = 0
	private(set) var saveSearchCallCount = 0
	private(set) var lastSavedQuery: String?

	func getRecentSearches() -> [String] {
		getRecentSearchesCallCount += 1
		return searches
	}

	func saveSearch(_ query: String) {
		saveSearchCallCount += 1
		lastSavedQuery = query
	}

	private(set) var deleteSearchCallCount = 0
	private(set) var lastDeletedQuery: String?

	func deleteSearch(_ query: String) {
		deleteSearchCallCount += 1
		lastDeletedQuery = query
	}
}
