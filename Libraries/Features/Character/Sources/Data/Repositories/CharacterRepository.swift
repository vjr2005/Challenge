import Foundation

/// Repository implementation for character data.
struct CharacterRepository: CharacterRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract

	init(remoteDataSource: CharacterRemoteDataSourceContract) {
		self.remoteDataSource = remoteDataSource
	}

	func getCharacter(id: Int) async throws -> Character {
		let dto = try await remoteDataSource.fetchCharacter(id: id)
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
