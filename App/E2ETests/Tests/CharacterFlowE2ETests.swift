import XCTest

/// End-to-end tests for the character browsing flow.
nonisolated final class CharacterFlowE2ETests: XCTestCase {
	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testCharacterBrowsingFlow() throws {
		let app = launch()

		home(app: app) { robot in
            robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList(app: app) { robot in
            robot.verifyIsVisible()
			robot.tapCharacter(id: 1)
		}

		characterDetail(app: app) { robot in
			robot.verifyIsVisible()
			robot.tapBack()
		}

		characterList(app: app) { robot in
			robot.verifyIsVisible()
			robot.tapBack()
		}

		home(app: app) { robot in
			robot.verifyIsVisible()
		}
	}
}
