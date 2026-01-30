import Foundation

@testable import ChallengeCharacter

/// Mock implementation of ClearCharactersCacheUseCaseContract for testing.
final class ClearCharactersCacheUseCaseMock: ClearCharactersCacheUseCaseContract, @unchecked Sendable {
	private(set) var executeCallCount = 0

	func execute() async {
		executeCallCount += 1
	}
}
