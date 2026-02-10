import ChallengeCoreMocks
import ChallengeNetworking
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeGraphQLDataSourceTests {
	private let graphQLClientMock = GraphQLClientMock()
	private let sut: EpisodeGraphQLDataSource

	init() {
		sut = EpisodeGraphQLDataSource(graphQLClient: graphQLClientMock)
	}

	// MARK: - Fetch Episodes

	@Test("Fetch episodes sends correct operation name")
	func fetchEpisodesSendsCorrectOperationName() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("episodes_by_character"))

		// When
		_ = try await sut.fetchEpisodes(characterIdentifier: 1)

		// Then
		let operation = try #require(graphQLClientMock.executedOperations.first)
		#expect(operation.operationName == "GetEpisodesByCharacter")
	}

	@Test("Fetch episodes sends correct query")
	func fetchEpisodesSendsCorrectQuery() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("episodes_by_character"))

		// When
		_ = try await sut.fetchEpisodes(characterIdentifier: 1)

		// Then
		let operation = try #require(graphQLClientMock.executedOperations.first)
		#expect(operation.query == EpisodeGraphQLDataSource.episodesByCharacterQuery)
	}

	@Test("Fetch episodes sends character identifier as string variable")
	func fetchEpisodesSendsCharacterIdentifier() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("episodes_by_character"))

		// When
		_ = try await sut.fetchEpisodes(characterIdentifier: 42)

		// Then
		let operation = try #require(graphQLClientMock.executedOperations.first)
		let variables = try #require(operation.variables)
		#expect(variables["id"] == .string("42"))
	}

	@Test("Fetch episodes decodes character fields from response")
	func fetchEpisodesDecodesCharacterFields() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("episodes_by_character"))

		// When
		let result = try await sut.fetchEpisodes(characterIdentifier: 1)

		// Then
		#expect(result.id == "1")
		#expect(result.name == "Rick Sanchez")
		#expect(result.image == "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
	}

	@Test("Fetch episodes decodes episodes from response")
	func fetchEpisodesDecodesEpisodes() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("episodes_by_character"))

		// When
		let result = try await sut.fetchEpisodes(characterIdentifier: 1)

		// Then
		#expect(result.episodes.count == 2)
		#expect(result.episodes[0].id == "1")
		#expect(result.episodes[0].name == "Pilot")
		#expect(result.episodes[0].airDate == "December 2, 2013")
		#expect(result.episodes[0].episode == "S01E01")
	}

	@Test("Fetch episodes decodes characters within episodes")
	func fetchEpisodesDecodesCharacters() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("episodes_by_character"))

		// When
		let result = try await sut.fetchEpisodes(characterIdentifier: 1)

		// Then
		#expect(result.episodes[0].characters.count == 2)
		#expect(result.episodes[0].characters[0].id == "1")
		#expect(result.episodes[0].characters[0].name == "Rick Sanchez")
		#expect(result.episodes[0].characters[0].image == "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
	}

	@Test("Fetch episodes maps GraphQL statusCode 404 to APIError.notFound")
	func fetchEpisodesMapsNotFoundError() async {
		// Given
		graphQLClientMock.result = .failure(GraphQLError.statusCode(404, Data()))

		// When / Then
		await #expect(throws: APIError.notFound) {
			_ = try await sut.fetchEpisodes(characterIdentifier: 1)
		}
	}

	@Test("Fetch episodes maps GraphQL statusCode 500 to APIError.serverError")
	func fetchEpisodesMapsServerError() async {
		// Given
		graphQLClientMock.result = .failure(GraphQLError.statusCode(500, Data()))

		// When / Then
		await #expect(throws: APIError.serverError(statusCode: 500)) {
			_ = try await sut.fetchEpisodes(characterIdentifier: 1)
		}
	}

	@Test("Fetch episodes maps GraphQL response errors to APIError.invalidResponse")
	func fetchEpisodesMapsResponseError() async {
		// Given
		let errors = [GraphQLResponseError(message: "Error", locations: nil, path: nil)]
		graphQLClientMock.result = .failure(GraphQLError.response(errors))

		// When / Then
		await #expect(throws: APIError.invalidResponse) {
			_ = try await sut.fetchEpisodes(characterIdentifier: 1)
		}
	}
}

// MARK: - Private

private extension EpisodeGraphQLDataSourceTests {
	func loadJSONData(_ filename: String) throws -> Data {
		try Bundle.module.loadJSONData(filename)
	}
}
