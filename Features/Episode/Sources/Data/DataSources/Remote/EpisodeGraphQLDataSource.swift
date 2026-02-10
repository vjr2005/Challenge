import ChallengeNetworking
import Foundation

struct EpisodeGraphQLDataSource: EpisodeRemoteDataSourceContract {
	private let graphQLClient: any GraphQLClientContract
	private let errorMapper = GraphQLErrorMapper()

	init(graphQLClient: any GraphQLClientContract) {
		self.graphQLClient = graphQLClient
	}

	func fetchEpisodes(characterIdentifier: Int) async throws -> EpisodeCharacterWithEpisodesDTO {
		let operation = GraphQLOperation(
			query: Self.episodesByCharacterQuery,
			variables: ["id": .string(String(characterIdentifier))],
			operationName: "GetEpisodesByCharacter"
		)

		let response: EpisodesByCharacterResponse = try await request(operation)
		return response.character
	}
}

// MARK: - Private

private extension EpisodeGraphQLDataSource {
	func request<T: Decodable>(_ operation: GraphQLOperation) async throws -> T {
		do {
			return try await graphQLClient.execute(operation)
		} catch let error as GraphQLError {
			throw errorMapper.map(error)
		}
	}
}

// MARK: - Response Wrappers

private struct EpisodesByCharacterResponse: Decodable {
	let character: EpisodeCharacterWithEpisodesDTO
}

// MARK: - Queries

extension EpisodeGraphQLDataSource {
	static let episodesByCharacterQuery = """
		query GetEpisodesByCharacter($id: ID!) {
			character(id: $id) {
				id
				name
				image
				episode {
					id
					name
					air_date
					episode
					characters {
						id
						name
						image
					}
				}
			}
		}
		"""
}
