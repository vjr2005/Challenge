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

	@Test("Make home view model creates HomeViewModel")
	func makeHomeViewModel() {
		// When
		let viewModel = sut.makeHomeViewModel(navigator: NavigatorMock())

		// Then
		#expect(viewModel is HomeViewModel)
	}

	@Test("Make about view model creates AboutViewModel")
	func makeAboutViewModel() {
		// When
		let viewModel = sut.makeAboutViewModel(navigator: NavigatorMock())

		// Then
		#expect(viewModel is AboutViewModel)
	}
}
