import ChallengeCoreMocks
import ChallengeNetworking
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterRESTDataSourceTests {
	// MARK: - Properties

	private let httpClientMock = HTTPClientMock()
	private let sut: CharacterRESTDataSource

	// MARK: - Initialization

	init() {
		sut = CharacterRESTDataSource(httpClient: httpClientMock)
	}

	// MARK: - Fetch Character Tests

	@Test("Fetch character uses correct endpoint path")
	func fetchCharacterUsesCorrectEndpoint() async throws {
		// Given
		let jsonData = try loadJSONData("character")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacter(identifier: 1)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		#expect(endpoint.path == "/api/character/1")
		#expect(endpoint.method == .get)
	}

	@Test("Fetch character decodes response correctly")
	func fetchCharacterDecodesResponseCorrectly() async throws {
		// Given
		let jsonData = try loadJSONData("character")
		httpClientMock.result = .success(jsonData)

		// When
		let value = try await sut.fetchCharacter(identifier: 1)

		// Then
		#expect(value.id == 1)
		#expect(value.name == "Rick Sanchez")
		#expect(value.status == "Alive")
		#expect(value.species == "Human")
	}

	@Test("Fetch character maps HTTP 404 to APIError.notFound")
	func fetchCharacterMapsHTTP404ToNotFound() async throws {
		// Given
		httpClientMock.result = .failure(HTTPError.statusCode(404, Data()))

		// When / Then
		await #expect(throws: APIError.notFound) {
			_ = try await sut.fetchCharacter(identifier: 999)
		}
	}

	@Test("Fetch character maps HTTP 500 to APIError.serverError")
	func fetchCharacterMapsHTTP500ToServerError() async throws {
		// Given
		httpClientMock.result = .failure(HTTPError.statusCode(500, Data()))

		// When / Then
		await #expect(throws: APIError.serverError(statusCode: 500)) {
			_ = try await sut.fetchCharacter(identifier: 1)
		}
	}

	@Test(arguments: [1, 2, 42, 826])
	func fetchCharacterUsesProvidedId(_ identifier: Int) async throws {
		// Given
		let jsonData = try loadJSONData("character")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacter(identifier: identifier)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.last)
		#expect(endpoint.path == "/api/character/\(identifier)")
	}

	// MARK: - Fetch Characters (Paginated)

	@Test("Fetch characters uses correct endpoint path")
	func fetchCharactersUsesCorrectEndpoint() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacters(page: 1, filter: .empty)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		#expect(endpoint.path == "/api/character")
	}

	@Test("Fetch characters includes page query item")
	func fetchCharactersIncludesPageQueryItem() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacters(page: 5, filter: .empty)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let queryItems = try #require(endpoint.queryItems)
		#expect(queryItems.contains(URLQueryItem(name: "page", value: "5")))
	}

	@Test("Fetch characters includes name query item when provided")
	func fetchCharactersIncludesNameQueryItem() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(name: "Rick"))

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let queryItems = try #require(endpoint.queryItems)
		#expect(queryItems.contains(URLQueryItem(name: "name", value: "Rick")))
	}

	@Test("Fetch characters omits name query item when nil")
	func fetchCharactersOmitsNameQueryItemWhenNil() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacters(page: 1, filter: .empty)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let queryItems = try #require(endpoint.queryItems)
		#expect(!queryItems.contains { $0.name == "name" })
	}

	@Test("Fetch characters omits name query item when empty")
	func fetchCharactersOmitsNameQueryItemWhenEmpty() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(name: ""))

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let queryItems = try #require(endpoint.queryItems)
		#expect(!queryItems.contains { $0.name == "name" })
	}

	@Test("Fetch characters includes status query item when provided")
	func fetchCharactersIncludesStatusQueryItem() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(status: .alive))

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let queryItems = try #require(endpoint.queryItems)
		#expect(queryItems.contains(URLQueryItem(name: "status", value: "alive")))
	}

	@Test("Fetch characters includes species query item when provided")
	func fetchCharactersIncludesSpeciesQueryItem() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(species: "Human"))

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let queryItems = try #require(endpoint.queryItems)
		#expect(queryItems.contains(URLQueryItem(name: "species", value: "Human")))
	}

	@Test("Fetch characters includes type query item when provided")
	func fetchCharactersIncludesTypeQueryItem() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(type: "Parasite"))

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let queryItems = try #require(endpoint.queryItems)
		#expect(queryItems.contains(URLQueryItem(name: "type", value: "Parasite")))
	}

	@Test("Fetch characters includes gender query item when provided")
	func fetchCharactersIncludesGenderQueryItem() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(gender: .female))

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let queryItems = try #require(endpoint.queryItems)
		#expect(queryItems.contains(URLQueryItem(name: "gender", value: "female")))
	}

	@Test("Fetch characters includes all filter query items when provided")
	func fetchCharactersIncludesAllFilterQueryItems() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)
		let filter = CharacterFilter(
			name: "Rick",
			status: .alive,
			species: "Human",
			type: "Scientist",
			gender: .male
		)

		// When
		_ = try await sut.fetchCharacters(page: 1, filter: filter)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let queryItems = try #require(endpoint.queryItems)
		#expect(queryItems.contains(URLQueryItem(name: "page", value: "1")))
		#expect(queryItems.contains(URLQueryItem(name: "name", value: "Rick")))
		#expect(queryItems.contains(URLQueryItem(name: "status", value: "alive")))
		#expect(queryItems.contains(URLQueryItem(name: "species", value: "Human")))
		#expect(queryItems.contains(URLQueryItem(name: "type", value: "Scientist")))
		#expect(queryItems.contains(URLQueryItem(name: "gender", value: "male")))
	}

	@Test("Fetch characters decodes response correctly")
	func fetchCharactersDecodesResponseCorrectly() async throws {
		// Given
		let jsonData = try loadJSONData("characters_response")
		httpClientMock.result = .success(jsonData)

		// When
		let value = try await sut.fetchCharacters(page: 1, filter: .empty)

		// Then
		#expect(value.info.count == 826)
		#expect(value.info.pages == 42)
		#expect(value.results.count == 1)
		#expect(value.results.first?.name == "Rick Sanchez")
	}

	@Test("Fetch characters maps HTTP 404 to APIError.notFound")
	func fetchCharactersMapsHTTP404ToNotFound() async throws {
		// Given
		httpClientMock.result = .failure(HTTPError.statusCode(404, Data()))

		// When / Then
		await #expect(throws: APIError.notFound) {
			_ = try await sut.fetchCharacters(page: 1, filter: .empty)
		}
	}

	@Test("Fetch characters maps HTTP 500 to APIError.serverError")
	func fetchCharactersMapsHTTP500ToServerError() async throws {
		// Given
		httpClientMock.result = .failure(HTTPError.statusCode(500, Data()))

		// When / Then
		await #expect(throws: APIError.serverError(statusCode: 500)) {
			_ = try await sut.fetchCharacters(page: 1, filter: .empty)
		}
	}
}

// MARK: - Private

private extension CharacterRESTDataSourceTests {
	func loadJSONData(_ filename: String) throws -> Data {
		try Bundle.module.loadJSONData(filename)
	}
}
