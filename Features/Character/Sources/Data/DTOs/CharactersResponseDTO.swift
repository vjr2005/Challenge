import Foundation

/// DTO for the pagination info from the Rick and Morty API.
struct PaginationInfoDTO: Decodable, Equatable, Sendable {
	let count: Int
	let pages: Int
	let next: String?
	let prev: String?
}

/// DTO for the paginated characters response from the Rick and Morty API.
struct CharactersResponseDTO: Decodable, Equatable, Sendable {
	let info: PaginationInfoDTO
	let results: [CharacterDTO]
}
