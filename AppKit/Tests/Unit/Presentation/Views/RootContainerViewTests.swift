import ChallengeNetworkingMocks
import Testing

@testable import ChallengeAppKit

struct RootContainerViewTests {
	// MARK: - Properties

	private let sut: RootContainerView

	// MARK: - Initialization

	init() {
		let appContainer = AppContainer(httpClient: HTTPClientMock())
		sut = RootContainerView(appContainer: appContainer)
	}

	// MARK: - Tests

	@Test("Initializes with NavigationStack coordinator")
	func initializesWithNavigationCoordinator() {
		// Then
		let viewName = String(describing: sut.body)
		#expect(viewName.contains("NavigationStack"))
	}
}
