import XCTest

/// UI tests for the Not Found screen shown on invalid deep links.
final class NotFoundUITests: UITestCase {
	@MainActor
	func testNotFoundScreenAndGoBack() async throws {
		// Given — all requests return 404
		await givenAllRequestsReturnNotFound()

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://invalid/route"))

		// Verify home is visible
		home { robot in
			robot.verifyIsVisible()
		}

		// When — open invalid deep link
		app.open(url)

		// Then — not found screen is visible
		notFound { robot in
			robot.verifyIsVisible()
			robot.tapGoBack()
		}

		// Verify home is visible after going back
		home { robot in
			robot.verifyIsVisible()
		}
	}
}
