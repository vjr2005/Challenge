import ChallengeNetworking
import Foundation

protocol CharacterRemoteDataSourceContract: Sendable {
	func fetchCharacter(identifier: Int) async throws -> CharacterDTO
	func fetchCharacters(page: Int, query: String?) async throws -> CharactersResponseDTO
}

struct CharacterRemoteDataSource: CharacterRemoteDataSourceContract {
	private let httpClient: HTTPClientContract

	init(httpClient: HTTPClientContract) {
		self.httpClient = httpClient
	}

	func fetchCharacter(identifier: Int) async throws -> CharacterDTO {
		let endpoint = Endpoint(path: "/character/\(identifier)")
		return try await httpClient.request(endpoint)
	}

	func fetchCharacters(page: Int, query: String?) async throws -> CharactersResponseDTO {
		var queryItems = [URLQueryItem(name: "page", value: String(page))]
		if let query, !query.isEmpty {
			queryItems.append(URLQueryItem(name: "name", value: query))
		}
		let endpoint = Endpoint(
			path: "/character",
			queryItems: queryItems
		)
		return try await httpClient.request(endpoint)
	}
}
