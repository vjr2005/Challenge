import Foundation

@testable import ChallengeCharacter

final class SaveRecentSearchUseCaseMock: SaveRecentSearchUseCaseContract, @unchecked Sendable {
	private(set) var executeCallCount = 0
	private(set) var savedQueries: [String] = []

	func execute(query: String) {
		executeCallCount += 1
		savedQueries.append(query)
	}
}
