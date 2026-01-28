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

	func getCharacter(identifier: Int) async throws -> Character {
		if let cachedDTO = await memoryDataSource.getCharacter(identifier: identifier) {
			return cachedDTO.toDomain()
		}

		let dto = try await remoteDataSource.fetchCharacter(identifier: identifier)

		await memoryDataSource.saveCharacter(dto)

		return dto.toDomain()
	}

	func getCharacters(page: Int) async throws -> CharactersPage {
		if let cachedResponse = await memoryDataSource.getPage(page) {
			return cachedResponse.toDomain(currentPage: page)
		}

		let response = try await remoteDataSource.fetchCharacters(page: page)

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
