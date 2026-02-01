import ChallengeCore
import ChallengeCoreMocks
import ChallengeHome
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeAppKit

struct AppContainerNavigationTests {
	// MARK: - Properties

	private let navigatorMock = NavigatorMock()
	private let sut: AppContainer

	// MARK: - Initialization

	init() {
		sut = AppContainer(httpClient: HTTPClientMock())
	}

	// MARK: - Resolve

	@Test("Resolve returns view when feature can handle navigation")
	func resolveReturnsViewWhenFeatureCanHandle() {
		// When
		let result = sut.resolve(HomeIncomingNavigation.main, navigator: navigatorMock)

		// Then
		let viewName = String(describing: result)
		#expect(!viewName.isEmpty)
	}

	@Test("Resolve returns NotFoundView when no feature can handle navigation")
	func resolveReturnsNotFoundViewWhenNoFeatureCanHandle() {
		// When
		let result = sut.resolve(TestNavigation.unknown, navigator: navigatorMock)

		// Then
		let viewName = String(describing: result)
		#expect(viewName.contains("NotFoundView"))
	}

	// MARK: - Deep Link Handling

	@Test("Handle URL navigates when feature can resolve deep link")
	func handleURLNavigatesWhenFeatureCanResolve() throws {
		// Given
		let url = try #require(URL(string: "challenge://character/list"))

		// When
		sut.handle(url: url, navigator: navigatorMock)

		// Then
		#expect(navigatorMock.navigatedDestinations.count == 1)
	}

	@Test("Handle URL navigates to NotFound when no feature can resolve deep link")
	func handleURLNavigatesToNotFoundWhenNoFeatureCanResolve() throws {
		// Given
		let url = try #require(URL(string: "challenge://unknown/path"))

		// When
		sut.handle(url: url, navigator: navigatorMock)

		// Then
		#expect(navigatorMock.navigatedDestinations.count == 1)
		let navigation = navigatorMock.navigatedDestinations.first as? UnknownNavigation
		#expect(navigation == .notFound)
	}
}

// MARK: - Test Helpers

private enum TestNavigation: NavigationContract {
	case unknown
}
