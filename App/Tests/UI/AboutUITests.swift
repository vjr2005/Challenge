import XCTest

/// UI tests for the About modal flow.
final class AboutUITests: UITestCase {
	@MainActor
	func testOpenAboutSheetAndVerifyContent() async throws {
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
			robot.verifyFeaturesExist()
			robot.verifyDeveloperExists()
		}
	}

	@MainActor
	func testOpenAboutSheetAndCloseReturnsToHome() async throws {
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
			robot.tapClose()
		}

		home { robot in
			robot.verifyIsVisible()
		}
	}
}
