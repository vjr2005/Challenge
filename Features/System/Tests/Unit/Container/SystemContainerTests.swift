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

	@Test("Make not found view model creates NotFoundViewModel")
	func makeNotFoundViewModel() {
		// When
		let viewModel = sut.makeNotFoundViewModel(navigator: NavigatorMock())

		// Then
		#expect(viewModel is NotFoundViewModel)
	}
}
