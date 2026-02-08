import Foundation

struct PaginationInfoDTO: Decodable, Equatable {
	let count: Int
	let pages: Int
	let next: String?
	let prev: String?
}

struct CharactersResponseDTO: Decodable, Equatable {
	let info: PaginationInfoDTO
	let results: [CharacterDTO]
}
