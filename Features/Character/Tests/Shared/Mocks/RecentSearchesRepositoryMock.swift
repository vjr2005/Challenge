import Foundation

@testable import ChallengeCharacter

nonisolated final class RecentSearchesRepositoryMock: RecentSearchesRepositoryContract, @unchecked Sendable {
	var searches: [String] = []
	private(set) var getRecentSearchesCallCount = 0
	private(set) var saveSearchCallCount = 0
	private(set) var lastSavedQuery: String?
	private(set) var deleteSearchCallCount = 0
	private(set) var lastDeletedQuery: String?

	@concurrent func getRecentSearches() async -> [String] {
		getRecentSearchesCallCount += 1
		return searches
	}

	@concurrent func saveSearch(_ query: String) async {
		saveSearchCallCount += 1
		lastSavedQuery = query
	}

	@concurrent func deleteSearch(_ query: String) async {
		deleteSearchCallCount += 1
		lastDeletedQuery = query
	}
}
