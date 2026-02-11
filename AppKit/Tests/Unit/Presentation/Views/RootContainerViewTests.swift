import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeAppKit

struct RootContainerViewTests {
	@Test("Initializes with app container and retains image loader")
	func initializesWithAppContainer() {
		// Given
		let imageLoaderMock = ImageLoaderMock(cachedImage: nil, asyncImage: nil)
		let appContainer = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock(), imageLoader: imageLoaderMock)

		// When
		let sut = RootContainerView(appContainer: appContainer)

		// Then
		#expect(sut.appContainer.imageLoader as AnyObject === imageLoaderMock)
	}
}
