import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeAppKit

struct RootViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	@Test("Renders root container view in initial state")
	func initialState() {
		// Given
		let httpClientMock = HTTPClientMock()
		let appContainer = AppContainer(httpClient: httpClientMock, tracker: TrackerMock())

		// When
		let view = RootContainerView(appContainer: appContainer)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}
