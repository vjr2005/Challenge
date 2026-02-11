import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworking
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeAppKit

struct AppContainerTests {
	// MARK: - Injected Dependencies

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

	@Test("Creates default dependencies when not provided")
	func createsDefaultDependencies() {
		// When
		let sut = AppContainer()

		// Then
		#expect(sut.imageLoader is CachedImageLoader)
	}

	// MARK: - Resolve View

	@Test("Resolve view falls back to NotFoundView when no feature handles navigation")
	func resolveViewFallsBackToNotFoundView() {
		// Given
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let navigatorMock = NavigatorMock()

		// When
		let result = sut.resolveView(for: TestNavigation.unknown, navigator: navigatorMock)

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

	@Test("Make root view returns home view when no deep link URL")
	func makeRootViewReturnsHomeViewWhenNoDeepLinkURL() {
		// Given
		let sut = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let navigatorMock = NavigatorMock()

		// When
		let view = sut.makeRootView(navigator: navigatorMock)

		// Then
		let viewName = String(describing: view)
		#expect(!viewName.isEmpty)
		#expect(navigatorMock.navigatedDestinations.isEmpty)
	}

	@Test("Make root view returns deep link view when deep link URL is valid")
	func makeRootViewReturnsDeepLinkViewWhenDeepLinkURLIsValid() {
		// Given
		let launchEnvironment = LaunchEnvironment(environment: ["DEEP_LINK_URL": "challenge://character/list"])
		let sut = AppContainer(launchEnvironment: launchEnvironment, httpClient: HTTPClientMock(), tracker: TrackerMock())
		let navigatorMock = NavigatorMock()

		// When
		let view = sut.makeRootView(navigator: navigatorMock)

		// Then
		let viewName = String(describing: view)
		#expect(!viewName.isEmpty)
		#expect(navigatorMock.navigatedDestinations.isEmpty)
	}

	@Test("Make root view returns NotFoundView when deep link URL is unknown")
	func makeRootViewReturnsNotFoundViewWhenDeepLinkURLIsUnknown() {
		// Given
		let launchEnvironment = LaunchEnvironment(environment: ["DEEP_LINK_URL": "challenge://unknown/path"])
		let sut = AppContainer(launchEnvironment: launchEnvironment, httpClient: HTTPClientMock(), tracker: TrackerMock())
		let navigatorMock = NavigatorMock()

		// When
		let view = sut.makeRootView(navigator: navigatorMock)

		// Then
		let viewName = String(describing: view)
		#expect(viewName.contains("NotFoundView"))
		#expect(navigatorMock.navigatedDestinations.isEmpty)
	}
}

// MARK: - Test Helpers

private enum TestNavigation: NavigationContract {
	case unknown
}
