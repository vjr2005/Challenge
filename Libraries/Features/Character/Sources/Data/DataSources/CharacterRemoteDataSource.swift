import ChallengeNetworking
import Foundation

/// Contract for fetching character data from a remote source.
protocol CharacterRemoteDataSourceContract: Sendable {
	func fetchCharacter(id: Int) async throws -> CharacterDTO
}

/// Remote data source implementation for character data.
struct CharacterRemoteDataSource: CharacterRemoteDataSourceContract {
	private let httpClient: HTTPClientContract

	init(httpClient: HTTPClientContract) {
		self.httpClient = httpClient
	}

	func fetchCharacter(id: Int) async throws -> CharacterDTO {
		let endpoint = Endpoint(path: "/character/\(id)")
		return try await httpClient.request(endpoint)
	}
}
