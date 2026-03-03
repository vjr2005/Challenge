import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import ChallengeSnapshotTestKit
import SwiftUI
import Testing

@testable import ChallengeAppKit

struct NavigationContainerViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	@Test("Renders navigation container view with content")
	func rendersNavigationContainerView() {
		// Given
		let appContainer = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let coordinator = NavigationCoordinator()

		// When
		let view = NavigationContainerView(
			navigationCoordinator: coordinator,
			appContainer: appContainer
		) {
			Text("Content")
		}

		// Then
		assertSnapshot(of: view, as: .device)
	}
}
