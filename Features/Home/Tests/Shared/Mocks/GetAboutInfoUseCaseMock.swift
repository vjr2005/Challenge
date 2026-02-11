@testable import ChallengeHome

final class GetAboutInfoUseCaseMock: GetAboutInfoUseCaseContract, @unchecked Sendable {
	var result = AboutInfo(sections: [])
	private(set) var executeCallCount = 0

	func execute() -> AboutInfo {
		executeCallCount += 1
		return result
	}
}
