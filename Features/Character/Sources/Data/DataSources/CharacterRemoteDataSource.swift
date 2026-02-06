import ChallengeNetworking
import Foundation

protocol CharacterRemoteDataSourceContract: Sendable {
	func fetchCharacter(identifier: Int) async throws -> CharacterDTO
	func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> CharactersResponseDTO
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

	func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> CharactersResponseDTO {
		var queryItems = [URLQueryItem(name: "page", value: String(page))]
		if let name = filter.name, !name.isEmpty {
			queryItems.append(URLQueryItem(name: "name", value: name))
		}
		if let status = filter.status {
			queryItems.append(URLQueryItem(name: "status", value: status.apiValue))
		}
		if let species = filter.species, !species.isEmpty {
			queryItems.append(URLQueryItem(name: "species", value: species))
		}
		if let type = filter.type, !type.isEmpty {
			queryItems.append(URLQueryItem(name: "type", value: type))
		}
		if let gender = filter.gender {
			queryItems.append(URLQueryItem(name: "gender", value: gender.apiValue))
		}
		let endpoint = Endpoint(
			path: "/character",
			queryItems: queryItems
		)
		return try await httpClient.request(endpoint)
	}
}

// MARK: - API Value Mapping

private extension CharacterStatus {
	var apiValue: String {
		rawValue.lowercased()
	}
}

private extension CharacterGender {
	var apiValue: String {
		rawValue.lowercased()
	}
}
