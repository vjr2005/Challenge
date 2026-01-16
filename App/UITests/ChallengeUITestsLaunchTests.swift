import XCTest

/// Smoke test to verify the app launches without crashing.
nonisolated final class ChallengeUITestsLaunchTests: XCTestCase {
	@MainActor
	func testAppLaunchesSuccessfully() throws {
		let app = XCUIApplication()
		app.launch()
		XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
	}
}
