import ChallengeNetworking
import Foundation

struct CharacterRESTDataSource: CharacterRemoteDataSourceContract {
	private let httpClient: any HTTPClientContract
	private let errorMapper = HTTPErrorMapper()

	init(httpClient: any HTTPClientContract) {
		self.httpClient = httpClient
	}

	func fetchCharacter(identifier: Int) async throws -> CharacterDTO {
		let endpoint = Endpoint(path: "/api/character/\(identifier)")
		return try await request(endpoint)
	}

	func fetchCharacters(page: Int, filter: CharacterFilterDTO) async throws -> CharactersResponseDTO {
		var queryItems = [URLQueryItem(name: "page", value: String(page))]
		if let name = filter.name, !name.isEmpty {
			queryItems.append(URLQueryItem(name: "name", value: name))
		}
		if let status = filter.status {
			queryItems.append(URLQueryItem(name: "status", value: status))
		}
		if let species = filter.species, !species.isEmpty {
			queryItems.append(URLQueryItem(name: "species", value: species))
		}
		if let type = filter.type, !type.isEmpty {
			queryItems.append(URLQueryItem(name: "type", value: type))
		}
		if let gender = filter.gender {
			queryItems.append(URLQueryItem(name: "gender", value: gender))
		}
		let endpoint = Endpoint(path: "/api/character", queryItems: queryItems)
		return try await request(endpoint)
	}
}

// MARK: - Private

private extension CharacterRESTDataSource {
	func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
		do {
			return try await httpClient.request(endpoint)
		} catch let error as HTTPError {
			throw errorMapper.map(error)
		}
	}
}

