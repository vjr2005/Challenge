import XCTest

/// End-to-end tests for the character browsing flow.
nonisolated final class CharacterFlowE2ETests: XCTestCase {
	override func setUpWithError() throws {
		continueAfterFailure = false
		executionTimeAllowance = 60
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

	@MainActor
	func testCharacterSearchFlow() throws {
		let app = launch()

		home(app: app) { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList(app: app) { robot in
			robot.verifyIsVisible()
			robot.typeSearch(text: "Rick")
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testCharacterSearchWithNoResultsShowsEmptyState() throws {
		let app = launch()

		home(app: app) { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList(app: app) { robot in
			robot.verifyIsVisible()
			robot.typeSearch(text: "ZZZZZNONEXISTENT")
			robot.verifyEmptyStateIsVisible()
		}
	}

	@MainActor
	func testCharacterListPagination() throws {
		let app = launch()

		home(app: app) { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList(app: app) { robot in
			robot.verifyIsVisible()
			robot.verifyLoadMoreButtonExists()
			robot.tapLoadMore()
			robot.verifyIsVisible()
			// After loading more, character with id 21 should exist (first of page 2)
			robot.verifyCharacterExists(id: 21)
		}
	}

	@MainActor
	func testCharacterListPullToRefresh() throws {
		let app = launch()

		home(app: app) { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList(app: app) { robot in
			robot.verifyIsVisible()
			robot.pullToRefresh()
			robot.verifyIsVisible()
		}
	}
}
