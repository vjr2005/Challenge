import Foundation

/// Repository implementation for character data using local-first policy.
/// Checks cache first, then fetches from remote if not found, and saves to cache.
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

	func getCharacter(identifier: Int) async throws -> Character {
		// Check cache first
		if let cachedDTO = await memoryDataSource.getCharacter(identifier: identifier) {
			return cachedDTO.toDomain()
		}

		// Fetch from remote
		let dto = try await remoteDataSource.fetchCharacter(identifier: identifier)

		// Save to cache
		await memoryDataSource.saveCharacter(dto)

		return dto.toDomain()
	}

	func getCharacters(page: Int) async throws -> CharactersPage {
		// Check cache first
		if let cachedResponse = await memoryDataSource.getPage(page) {
			return cachedResponse.toDomain(currentPage: page)
		}

		// Fetch from remote
		let response = try await remoteDataSource.fetchCharacters(page: page)

		// Save page to cache (also saves individual characters)
		await memoryDataSource.savePage(response, page: page)

		return response.toDomain(currentPage: page)
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
			gender: gender,
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
