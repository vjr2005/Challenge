import ChallengeNetworkingMocks
import SnapshotTesting
import SwiftUI
import Testing

@testable import Challenge

struct RootViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	@Test
	func initialState() {
		// Given
		let httpClient = HTTPClientMock()
		let appContainer = AppContainer(httpClient: httpClient)

		// When
		let view = appContainer.makeRootView()

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}
