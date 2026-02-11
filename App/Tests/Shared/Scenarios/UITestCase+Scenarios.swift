import SwiftMockServer
import XCTest

// MARK: - Initial Scenarios

extension UITestCase {
	/// Configures avatars and character list responses. Use before `launch()`.
	func givenCharacterListSucceeds() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character") {
				return .json(charactersData)
			}
			return .status(.notFound)
		}
	}

	/// Configures avatars, character list, and character detail responses. Use before `launch()`.
	func givenCharacterListAndDetailSucceeds() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let characterData = Data.fixture("character", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character/") {
				return .json(characterData)
			}
			if request.path.contains("/character") {
				return .json(charactersData)
			}
			return .status(.notFound)
		}
	}

	/// Configures avatars and character list with page 2 support. Use before `launch()`.
	func givenCharacterListWithPaginationSucceeds() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let page1Data = Data.fixture("characters_response", baseURL: baseURL)
		let page2Data = Data.fixture("characters_response_page_2", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character") {
				if request.queryParameters["page"] == "2" {
					return .json(page2Data)
				}
				return .json(page1Data)
			}
			return .status(.notFound)
		}
	}

	/// Configures avatars, character list with page 2 support, and empty search results.
	func givenCharacterListWithPaginationAndEmptySearchSucceeds() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let page1Data = Data.fixture("characters_response", baseURL: baseURL)
		let page2Data = Data.fixture("characters_response_page_2", baseURL: baseURL)
		let emptyData = Data.fixture("characters_response_empty")
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character") {
				if request.queryParameters["name"] != nil {
					return .json(emptyData)
				}
				if request.queryParameters["page"] == "2" {
					return .json(page2Data)
				}
				return .json(page1Data)
			}
			return .status(.notFound)
		}
	}

	/// Configures avatars and character list where search returns empty. Use before `launch()`.
	func givenCharacterListWithEmptySearchSucceeds() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let emptyData = Data.fixture("characters_response_empty")
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character") {
				if request.queryParameters["name"] != nil {
					return .json(emptyData)
				}
				return .json(charactersData)
			}
			return .status(.notFound)
		}
	}

	/// Configures all requests to return 500 Internal Server Error. Use before `launch()`.
	func givenAllRequestsFail() async {
		await serverMock.registerCatchAll { _ in
			.status(.internalServerError)
		}
	}

	/// Configures avatars and list to succeed, but detail returns 500. Use before `launch()`.
	func givenCharacterDetailFailsButListSucceeds() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character/") {
				return .status(.internalServerError)
			}
			if request.path.contains("/character") {
				return .json(charactersData)
			}
			return .status(.notFound)
		}
	}

	/// Configures all requests to return 404 Not Found. Use before `launch()`.
	func givenAllRequestsReturnNotFound() async {
		await serverMock.registerCatchAll { _ in
			.status(.notFound)
		}
	}

	/// Configures avatars and character detail (no list). Use before `launch()` for deep link detail.
	func givenCharacterDetailSucceeds() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let characterData = Data.fixture("character", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character/") {
				return .json(characterData)
			}
			return .status(.notFound)
		}
	}

	/// Configures avatars, character list, detail, and episodes (GraphQL) responses. Use before `launch()`.
	func givenCharacterListDetailAndEpisodesSucceeds() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let characterData = Data.fixture("character", baseURL: baseURL)
		let episodesData = Data.fixture("episodes_by_character_response", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/graphql") {
				return .json(episodesData)
			}
			if request.path.contains("/character/") {
				return .json(characterData)
			}
			if request.path.contains("/character") {
				return .json(charactersData)
			}
			return .status(.notFound)
		}
	}

	/// Configures avatars, character list, and detail to succeed, but GraphQL episodes returns 500. Use before `launch()`.
	func givenCharacterEpisodesFailsButListAndDetailSucceeds() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let characterData = Data.fixture("character", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/graphql") {
				return .status(.internalServerError)
			}
			if request.path.contains("/character/") {
				return .json(characterData)
			}
			if request.path.contains("/character") {
				return .json(charactersData)
			}
			return .status(.notFound)
		}
	}
}

// MARK: - Recovery Scenarios

extension UITestCase {
	/// Registers avatar and character list routes for retry recovery. Use mid-test after initial failure.
	func givenCharacterListRecovers() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerPrefix(.GET, "/avatar/") { _ in .image(imageData) }
		await serverMock.register(.GET, "/api/character") { _ in .json(charactersData) }
	}

	/// Registers character detail route for retry recovery. Use mid-test after initial failure.
	func givenCharacterDetailRecovers() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let characterData = Data.fixture("character", baseURL: baseURL)

		await serverMock.registerPrefix(.GET, "/api/character/") { _ in .json(characterData) }
	}

	/// Registers all routes for retry recovery with episodes succeeding. Use mid-test after initial failure.
	func givenCharacterEpisodesRecovers() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let characterData = Data.fixture("character", baseURL: baseURL)
		let episodesData = Data.fixture("episodes_by_character_response", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/graphql") {
				return .json(episodesData)
			}
			if request.path.contains("/character/") {
				return .json(characterData)
			}
			return .status(.notFound)
		}
	}

	/// Registers all routes with GraphQL episodes returning 500. Use mid-test to simulate refresh failure.
	func givenCharacterEpisodesFails() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let characterData = Data.fixture("character", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/graphql") {
				return .status(.internalServerError)
			}
			if request.path.contains("/character/") {
				return .json(characterData)
			}
			return .status(.notFound)
		}
	}
}
