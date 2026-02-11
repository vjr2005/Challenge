import XCTest

/// UI tests for the character episodes screen: error/retry, pull-to-refresh, and character navigation.
final class CharacterEpisodesUITests: UITestCase {
	@MainActor
	func testCharacterEpisodesErrorRetryRefreshCharacterDetailAndBack() async throws {
		// Given — all requests fail
		await givenAllRequestsFail()

		let url = try XCTUnwrap(URL(string: "challenge://episode/character/1"))

		// When — launch with deep link to character episodes
		launch(deepLink: url)

		// Then — error screen is visible
		characterEpisodes { robot in
			robot.verifyErrorIsVisible()
		}

		// Recovery — configure episodes, detail, and avatar responses
		try await givenCharacterEpisodesRecovers()

		// Retry — episodes load
		characterEpisodes { robot in
			robot.tapRetry()
			robot.verifyIsVisible()

			// Pull to refresh — episodes still visible
			robot.pullToRefresh()
			robot.verifyIsVisible()

			// Tap first character from the first episode
			robot.tapCharacter(identifier: 1)
		}

		// Verify character detail is visible
		characterDetail { robot in
			robot.verifyIsVisible()
			robot.tapBack()
		}

		// Verify episodes screen is visible after going back
		characterEpisodes { robot in
			robot.verifyIsVisible()
		}
	}
}
