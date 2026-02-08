import ChallengeCore
import ChallengeCoreMocks
import ChallengeHome
import ChallengeNetworking
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeAppKit

struct AppContainerTests {
	// MARK: - Injected Dependencies

	@Test("Uses injected HTTP client")
	func usesInjectedHTTPClient() {
		// Given
		let httpClientMock = HTTPClientMock()

		// When
		let sut = AppContainer(httpClient: httpClientMock, tracker: TrackerMock())

		// Then
		#expect(sut.httpClient as AnyObject === httpClientMock)
	}

	@Test("Uses injected tracker")
	func usesInjectedTracker() {
		// Given
		let trackerMock = TrackerMock()

		// When
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: trackerMock)

		// Then
		#expect(sut.tracker as AnyObject === trackerMock)
	}

	@Test("Uses injected image loader")
	func usesInjectedImageLoader() {
		// Given
		let imageLoaderMock = ImageLoaderMock(cachedImage: nil, asyncImage: nil)

		// When
		let sut = AppContainer(
			httpClient: HTTPClientMock(),
			tracker: TrackerMock(),
			imageLoader: imageLoaderMock
		)

		// Then
		#expect(sut.imageLoader as AnyObject === imageLoaderMock)
	}

	// MARK: - Default Dependencies

	@Test("Creates default CachedImageLoader when image loader is not provided")
	func createsDefaultImageLoader() {
		// When
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())

		// Then
		#expect(sut.imageLoader is CachedImageLoader)
	}

	@Test("Creates default Tracker when tracker is not provided")
	func createsDefaultTracker() {
		// When
		let sut = AppContainer(httpClient: HTTPClientMock())

		// Then
		#expect(sut.tracker is Tracker)
	}

	@Test("Creates default HTTPClient when http client is not provided")
	func createsDefaultHTTPClient() {
		// When
		let sut = AppContainer(tracker: TrackerMock())

		// Then
		#expect(sut.httpClient is HTTPClient)
	}

	// MARK: - Features

	@Test("Features returns three features")
	func featuresReturnsThreeFeatures() {
		// Given
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())

		// When
		let features = sut.features

		// Then
		#expect(features.count == 3)
	}

	// MARK: - Resolve

	@Test("Resolve returns view when feature handles navigation")
	func resolveReturnsViewWhenFeatureHandlesNavigation() {
		// Given
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let navigatorMock = NavigatorMock()

		// When
		let result = sut.resolve(HomeIncomingNavigation.main, navigator: navigatorMock)

		// Then
		let viewName = String(describing: result)
		#expect(!viewName.isEmpty)
	}

	@Test("Resolve falls back to NotFoundView when no feature handles navigation")
	func resolveFallsBackToNotFoundView() {
		// Given
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let navigatorMock = NavigatorMock()

		// When
		let result = sut.resolve(TestNavigation.unknown, navigator: navigatorMock)

		// Then
		let viewName = String(describing: result)
		#expect(viewName.contains("NotFoundView"))
	}

	// MARK: - Deep Link Handling

	@Test("Handle URL navigates when feature resolves deep link")
	func handleURLNavigatesWhenFeatureResolvesDeepLink() throws {
		// Given
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let navigatorMock = NavigatorMock()
		let url = try #require(URL(string: "challenge://character/list"))

		// When
		sut.handle(url: url, navigator: navigatorMock)

		// Then
		#expect(navigatorMock.navigatedDestinations.count == 1)
	}

	@Test("Handle URL navigates to NotFound when no feature resolves deep link")
	func handleURLNavigatesToNotFoundWhenNoFeatureResolvesDeepLink() throws {
		// Given
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let navigatorMock = NavigatorMock()
		let url = try #require(URL(string: "challenge://unknown/path"))

		// When
		sut.handle(url: url, navigator: navigatorMock)

		// Then
		#expect(navigatorMock.navigatedDestinations.count == 1)
		let navigation = navigatorMock.navigatedDestinations.first as? UnknownNavigation
		#expect(navigation == .notFound)
	}

	// MARK: - Factory Methods

	@Test("Make root view returns a view")
	func makeRootViewReturnsView() {
		// Given
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let navigatorMock = NavigatorMock()

		// When
		let view = sut.makeRootView(navigator: navigatorMock)

		// Then
		let viewName = String(describing: view)
		#expect(!viewName.isEmpty)
	}
}

// MARK: - Test Helpers

private enum TestNavigation: NavigationContract {
	case unknown
}
