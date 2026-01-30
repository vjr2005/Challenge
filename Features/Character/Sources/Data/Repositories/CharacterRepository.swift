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

	func getCharacter(identifier: Int) async throws(CharacterError) -> Character {
		if let cachedDTO = await memoryDataSource.getCharacter(identifier: identifier) {
			return cachedDTO.toDomain()
		}

		do {
			let dto = try await remoteDataSource.fetchCharacter(identifier: identifier)
			await memoryDataSource.saveCharacter(dto)
			return dto.toDomain()
		} catch let error as HTTPError {
			throw mapHTTPError(error, identifier: identifier)
		} catch {
			throw .loadFailed
		}
	}

	func getCharacters(page: Int) async throws(CharacterError) -> CharactersPage {
		if let cachedResponse = await memoryDataSource.getPage(page) {
			return cachedResponse.toDomain(currentPage: page)
		}

		do {
			let response = try await remoteDataSource.fetchCharacters(page: page, query: nil)
			await memoryDataSource.savePage(response, page: page)
			return response.toDomain(currentPage: page)
		} catch let error as HTTPError {
			throw mapHTTPError(error, page: page)
		} catch {
			throw .loadFailed
		}
	}

	func searchCharacters(page: Int, query: String) async throws(CharacterError) -> CharactersPage {
		do {
			let response = try await remoteDataSource.fetchCharacters(page: page, query: query)
			return response.toDomain(currentPage: page)
		} catch let error as HTTPError {
			throw mapHTTPError(error, page: page)
		} catch {
			throw .loadFailed
		}
	}

	func refreshCharacter(identifier: Int) async throws(CharacterError) -> Character {
		do {
			let dto = try await remoteDataSource.fetchCharacter(identifier: identifier)
			await memoryDataSource.updateCharacterInPages(dto)
			return dto.toDomain()
		} catch let error as HTTPError {
			throw mapHTTPError(error, identifier: identifier)
		} catch {
			throw .loadFailed
		}
	}

	func clearPagesCache() async {
		await memoryDataSource.clearPages()
	}
}

// MARK: - Error Mapping

private extension CharacterRepository {
	func mapHTTPError(_ error: HTTPError, identifier: Int) -> CharacterError {
		switch error {
		case .statusCode(404, _):
			return .characterNotFound(id: identifier)
		case .invalidURL, .invalidResponse, .statusCode:
			return .loadFailed
		}
	}

	func mapHTTPError(_ error: HTTPError, page: Int) -> CharacterError {
		switch error {
		case .statusCode(404, _):
			return .invalidPage(page: page)
		case .invalidURL, .invalidResponse, .statusCode:
			return .loadFailed
		}
	}
}

// MARK: - DTO to Domain Mapping

extension CharacterDTO {
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

extension LocationDTO {
	func toDomain() -> Location {
		Location(
			name: name,
			url: URL(string: url)
		)
	}
}

extension CharactersResponseDTO {
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
