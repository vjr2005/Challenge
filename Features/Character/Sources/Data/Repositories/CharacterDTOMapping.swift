import Foundation

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
