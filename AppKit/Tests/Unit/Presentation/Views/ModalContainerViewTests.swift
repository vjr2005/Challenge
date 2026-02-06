import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeAppKit

struct ModalContainerViewTests {
	@Test("Initializes with modal, app container and onDismiss")
	func initializesWithModalAndAppContainer() {
		// Given
		let appContainer = AppContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
		let modal = ModalNavigation(navigation: TestNavigation.test, style: .sheet())

		// When
		let sut = ModalContainerView(modal: modal, appContainer: appContainer, onDismiss: {})

		// Then
		#expect(sut.modal.id == modal.id)
	}
}

// MARK: - Test Helpers

private enum TestNavigation: NavigationContract {
	case test
}
