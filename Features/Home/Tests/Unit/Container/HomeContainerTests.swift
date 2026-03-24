import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeContainerTests {
	// MARK: - Properties

	private let sut: HomeContainer

	// MARK: - Initialization

	init() {
		sut = HomeContainer(tracker: TrackerMock())
	}

	// MARK: - Tests

	@Test("Make home view creates HomeView")
	func makeHomeView() {
		// When
		let view = sut.makeHomeView(navigator: NavigatorMock())

		// Then
		let viewName = String(describing: type(of: view))
		#expect(viewName.contains("HomeView"))
	}

	@Test("Make about view creates AboutView")
	func makeAboutView() {
		// When
		let view = sut.makeAboutView(navigator: NavigatorMock())

		// Then
		let viewName = String(describing: type(of: view))
		#expect(viewName.contains("AboutView"))
	}
}
