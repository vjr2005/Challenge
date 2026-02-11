import XCTest

/// UI tests for deep link navigation.
final class DeepLinkUITests: UITestCase {
	@MainActor
	func testDeepLinkToCharacterList() async throws {
		// Given
		try await givenCharacterListSucceeds()

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://character/list"))

		// When
		app.open(url)

		// Then
		characterList { robot in
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testDeepLinkToCharacterDetail() async throws {
		// Given
		try await givenCharacterDetailSucceeds()

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://character/detail/1"))

		// When
		app.open(url)

		// Then
		characterDetail { robot in
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testInvalidDeepLinkShowsNotFound() async throws {
		// Given
		await givenAllRequestsReturnNotFound()

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://invalid/route"))

		// When
		app.open(url)

		// Then
		notFound { robot in
			robot.verifyIsVisible()
			robot.tapGoBack()
		}

		home { robot in
			robot.verifyIsVisible()
		}
	}

	// MARK: - Launch Deep Link

	@MainActor
	func testLaunchDeepLinkToCharacterList() async throws {
		// Given
		try await givenCharacterListSucceeds()

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://character/list"))

		// When
		app.open(url)

		// Then
		characterList { robot in
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testLaunchDeepLinkToCharacterDetail() async throws {
		// Given
		try await givenCharacterDetailSucceeds()

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://character/detail/1"))

		// When
		app.open(url)

		// Then
		characterDetail { robot in
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testLaunchInvalidDeepLinkShowsNotFound() async throws {
		// Given
		await givenAllRequestsReturnNotFound()

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://invalid/route"))

		// When
		app.open(url)

		// Then
		notFound { robot in
			robot.verifyIsVisible()
		}
	}
}
