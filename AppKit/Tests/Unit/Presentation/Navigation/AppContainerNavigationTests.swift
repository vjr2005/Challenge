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

	@Test
	func resolveReturnsViewWhenFeatureCanHandle() {
		// When
		let result = sut.resolve(HomeIncomingNavigation.main, navigator: navigatorMock)

		// Then
		let viewName = String(describing: result)
		#expect(!viewName.isEmpty)
	}

	@Test
	func resolveReturnsNotFoundViewWhenNoFeatureCanHandle() {
		// When
		let result = sut.resolve(TestNavigation.unknown, navigator: navigatorMock)

		// Then
		let viewName = String(describing: result)
		#expect(viewName.contains("NotFoundView"))
	}

	// MARK: - Deep Link Handling

	@Test
	func handleURLNavigatesWhenFeatureCanResolve() throws {
		// Given
		let url = try #require(URL(string: "challenge://character/list"))

		// When
		sut.handle(url: url, navigator: navigatorMock)

		// Then
		#expect(navigatorMock.navigatedDestinations.count == 1)
	}

	@Test
	func handleURLDoesNotNavigateWhenNoFeatureCanResolve() throws {
		// Given
		let url = try #require(URL(string: "challenge://unknown/path"))

		// When
		sut.handle(url: url, navigator: navigatorMock)

		// Then
		#expect(navigatorMock.navigatedDestinations.isEmpty)
	}
}

// MARK: - Test Helpers

private enum TestNavigation: Navigation {
	case unknown
}
