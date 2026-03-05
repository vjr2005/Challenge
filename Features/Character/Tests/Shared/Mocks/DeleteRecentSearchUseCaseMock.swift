import Foundation

@testable import ChallengeCharacter

final class DeleteRecentSearchUseCaseMock: DeleteRecentSearchUseCaseContract, @unchecked Sendable {
	private(set) var executeCallCount = 0
	private(set) var deletedQueries: [String] = []

	func execute(query: String) async {
		executeCallCount += 1
		deletedQueries.append(query)
	}
}
