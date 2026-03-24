import ChallengeCoreMocks
import Testing

@testable import ChallengeSystem

struct SystemContainerTests {
	// MARK: - Properties

	private let sut: SystemContainer

	// MARK: - Initialization

	init() {
		sut = SystemContainer(tracker: TrackerMock())
	}

	// MARK: - Tests

	@Test("Make not found view creates NotFoundView")
	func makeNotFoundView() {
		// When
		let view = sut.makeNotFoundView(navigator: NavigatorMock())

		// Then
		let viewName = String(describing: type(of: view))
		#expect(viewName.contains("NotFoundView"))
	}
}
