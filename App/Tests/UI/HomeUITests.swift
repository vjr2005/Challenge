import XCTest

/// UI tests for the Home screen flow.
final class HomeUITests: UITestCase {
	@MainActor
	func testHomeFlowOpenAboutExpandScrollCloseAndNavigateToCharacters() async throws {
		// Given
		try await givenCharacterListSucceeds()

		// When
		launch()

		// Then
		home { robot in
			robot.verifyIsVisible()
			robot.tapInfoButton()
		}

		about { robot in
			robot.verifyIsVisible()
			robot.swipeUp()
			robot.verifyCreditsExist()
			robot.tapClose()
		}

		home { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
		}
	}
}
