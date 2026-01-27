import ChallengeNetworking
import Foundation

protocol CharacterRemoteDataSourceContract: Sendable {
	func fetchCharacter(identifier: Int) async throws -> CharacterDTO
	func fetchCharacters(page: Int) async throws -> CharactersResponseDTO
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

	func fetchCharacters(page: Int) async throws -> CharactersResponseDTO {
		let endpoint = Endpoint(
			path: "/character",
			queryItems: [URLQueryItem(name: "page", value: String(page))]
		)
		return try await httpClient.request(endpoint)
	}
}
