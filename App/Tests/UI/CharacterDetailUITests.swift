import XCTest

/// UI tests for the character detail screen: error/retry, pull-to-refresh, and episodes navigation.
final class CharacterDetailUITests: UITestCase {
	@MainActor
	func testCharacterDetailErrorRetryRefreshEpisodesAndBack() async throws {
		// Given — all requests fail
		await givenAllRequestsFail()

		let url = try XCTUnwrap(URL(string: "challenge://character/detail/1"))

		// When — launch with deep link to character detail
		launch(deepLink: url)

		// Then — error screen is visible
		characterDetail { robot in
			robot.verifyErrorIsVisible()
		}

		// Recovery — configure detail and avatar responses
		try await givenCharacterDetailSucceeds()

		// Retry — detail loads
		characterDetail { robot in
			robot.tapRetry()
			robot.verifyIsVisible()

			// Pull to refresh — detail still visible
			robot.pullToRefresh()
			robot.verifyIsVisible()
		}

		// Configure episodes (GraphQL) for the next step
		try await givenCharacterEpisodesRecovers()

		// Tap episodes — verify episodes list is visible
		characterDetail { robot in
			robot.tapEpisodes()
		}

		characterEpisodes { robot in
			robot.verifyIsVisible()
			robot.tapBack()
		}

		characterDetail { robot in
			robot.verifyIsVisible()
		}
	}
}
