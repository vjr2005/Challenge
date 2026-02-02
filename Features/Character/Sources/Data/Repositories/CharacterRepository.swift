import ChallengeNetworking
import Foundation

struct CharacterRepository: CharacterRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract
	private let memoryDataSource: CharacterMemoryDataSourceContract

	init(
		remoteDataSource: CharacterRemoteDataSourceContract,
		memoryDataSource: CharacterMemoryDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	func getCharacterDetail(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
		switch cachePolicy {
		case .localFirst:
			try await getCharacterDetailLocalFirst(identifier: identifier)
		case .remoteFirst:
			try await getCharacterDetailRemoteFirst(identifier: identifier)
		case .none:
			try await getCharacterDetailNoCache(identifier: identifier)
		}
	}

	func getCharacters(page: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> CharactersPage {
		switch cachePolicy {
		case .localFirst:
			try await getCharactersLocalFirst(page: page)
		case .remoteFirst:
			try await getCharactersRemoteFirst(page: page)
		case .none:
			try await getCharactersNoCache(page: page)
		}
	}

	func searchCharacters(page: Int, query: String) async throws(CharacterError) -> CharactersPage {
		do {
			let response = try await remoteDataSource.fetchCharacters(page: page, query: query)
			return response.toDomain(currentPage: page)
		} catch let error as HTTPError {
			if case .statusCode(404, _) = error {
				return .empty(currentPage: page)
			}
			throw mapHTTPError(error, page: page)
		} catch {
			throw .loadFailed
		}
	}
}

// MARK: - Remote Fetch Helpers

private extension CharacterRepository {
	func fetchCharacterFromRemote(identifier: Int) async throws(CharacterError) -> CharacterDTO {
		do {
			return try await remoteDataSource.fetchCharacter(identifier: identifier)
		} catch let error as HTTPError {
			throw mapHTTPError(error, identifier: identifier)
		} catch {
			throw .loadFailed
		}
	}

	func fetchCharactersFromRemote(page: Int, query: String? = nil) async throws(CharacterError) -> CharactersResponseDTO {
		do {
			return try await remoteDataSource.fetchCharacters(page: page, query: query)
		} catch let error as HTTPError {
			throw mapHTTPError(error, page: page)
		} catch {
			throw .loadFailed
		}
	}

}

// MARK: - Character Detail Cache Strategies

private extension CharacterRepository {
	func getCharacterDetailLocalFirst(identifier: Int) async throws(CharacterError) -> Character {
		if let cached = await memoryDataSource.getCharacterDetail(identifier: identifier) {
			return cached.toDomain()
		}
		let dto = try await fetchCharacterFromRemote(identifier: identifier)
		await memoryDataSource.saveCharacterDetail(dto)
		return dto.toDomain()
	}

	func getCharacterDetailRemoteFirst(identifier: Int) async throws(CharacterError) -> Character {
		do {
			let dto = try await fetchCharacterFromRemote(identifier: identifier)
			await memoryDataSource.saveCharacterDetail(dto)
			return dto.toDomain()
		} catch {
			if let cached = await memoryDataSource.getCharacterDetail(identifier: identifier) {
				return cached.toDomain()
			}
			throw error
		}
	}

	func getCharacterDetailNoCache(identifier: Int) async throws(CharacterError) -> Character {
		let dto = try await fetchCharacterFromRemote(identifier: identifier)
		return dto.toDomain()
	}
}

// MARK: - Characters Page Cache Strategies

private extension CharacterRepository {
	func getCharactersLocalFirst(page: Int) async throws(CharacterError) -> CharactersPage {
		if let cached = await memoryDataSource.getPage(page) {
			return cached.toDomain(currentPage: page)
		}
		let response = try await fetchCharactersFromRemote(page: page)
		await memoryDataSource.savePage(response, page: page)
		return response.toDomain(currentPage: page)
	}

	func getCharactersRemoteFirst(page: Int) async throws(CharacterError) -> CharactersPage {
		do {
			let response = try await fetchCharactersFromRemote(page: page)
			await memoryDataSource.savePage(response, page: page)
			return response.toDomain(currentPage: page)
		} catch {
			if let cached = await memoryDataSource.getPage(page) {
				return cached.toDomain(currentPage: page)
			}
			throw error
		}
	}

	func getCharactersNoCache(page: Int) async throws(CharacterError) -> CharactersPage {
		let response = try await fetchCharactersFromRemote(page: page)
		return response.toDomain(currentPage: page)
	}
}

// MARK: - Error Mapping

private extension CharacterRepository {
	func mapHTTPError(_ error: HTTPError, identifier: Int) -> CharacterError {
		switch error {
		case .statusCode(404, _):
			.characterNotFound(identifier: identifier)
		case .invalidURL, .invalidResponse, .statusCode:
			.loadFailed
		}
	}

	func mapHTTPError(_ error: HTTPError, page: Int) -> CharacterError {
		switch error {
		case .statusCode(404, _):
			.invalidPage(page: page)
		case .invalidURL, .invalidResponse, .statusCode:
			.loadFailed
		}
	}
}

// MARK: - DTO to Domain Mapping

private extension CharacterDTO {
	func toDomain() -> Character {
		Character(
			id: id,
			name: name,
			status: CharacterStatus(from: status),
			species: species,
			gender: CharacterGender(from: gender),
			origin: origin.toDomain(),
			location: location.toDomain(),
			imageURL: URL(string: image)
		)
	}
}

private extension LocationDTO {
	func toDomain() -> Location {
		Location(
			name: name,
			url: URL(string: url)
		)
	}
}

private extension CharactersResponseDTO {
	func toDomain(currentPage: Int) -> CharactersPage {
		CharactersPage(
			characters: results.map { $0.toDomain() },
			currentPage: currentPage,
			totalPages: info.pages,
			totalCount: info.count,
			hasNextPage: info.next != nil,
			hasPreviousPage: info.prev != nil
		)
	}
}
