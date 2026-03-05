import Foundation

@testable import ChallengeCharacter

final class GetRecentSearchesUseCaseMock: GetRecentSearchesUseCaseContract, @unchecked Sendable {
	var searches: [String] = []
	private(set) var executeCallCount = 0

	func execute() async -> [String] {
		executeCallCount += 1
		return searches
	}
}
