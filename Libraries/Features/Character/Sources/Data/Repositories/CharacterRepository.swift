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

	func getCharacter(id: Int) async throws -> Character {
		// Check cache first
		if let cachedDTO = await memoryDataSource.getCharacter(id: id) {
			return cachedDTO.toDomain()
		}

		// Fetch from remote
		let dto = try await remoteDataSource.fetchCharacter(id: id)

		// Save to cache
		await memoryDataSource.saveCharacter(dto)

		return dto.toDomain()
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
