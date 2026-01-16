import Foundation

/// DTO for the pagination info from the Rick and Morty API.
nonisolated struct PaginationInfoDTO: Decodable, Equatable {
	let count: Int
	let pages: Int
	let next: String?
	let prev: String?
}

/// DTO for the paginated characters response from the Rick and Morty API.
nonisolated struct CharactersResponseDTO: Decodable, Equatable {
	let info: PaginationInfoDTO
	let results: [CharacterDTO]
}
