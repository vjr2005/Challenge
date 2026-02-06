import ChallengeCore
import ChallengeCoreMocks
import ChallengeHome
import ChallengeNetworkingMocks
import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeAppKit

struct ModalContainerViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	@Test("Renders modal container view with resolved content")
	func rendersModalContainerView() {
		// Given
		let appContainer = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let modal = ModalNavigation(navigation: HomeIncomingNavigation.main, style: .sheet())

		// When
		let view = ModalContainerView(modal: modal, appContainer: appContainer, onDismiss: {})

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}
