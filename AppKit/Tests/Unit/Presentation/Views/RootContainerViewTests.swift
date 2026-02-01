import ChallengeNetworkingMocks
import Testing

@testable import ChallengeAppKit

struct RootContainerViewTests {
	@Test("Initializes with app container and retains http client")
	func initializesWithAppContainer() {
		// Given
		let httpClientMock = HTTPClientMock()
		let appContainer = AppContainer(httpClient: httpClientMock)

		// When
		let sut = RootContainerView(appContainer: appContainer)

		// Then
		#expect(sut.appContainer.httpClient as AnyObject === httpClientMock)
	}
}
