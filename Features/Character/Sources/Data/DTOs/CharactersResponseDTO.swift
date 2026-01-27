import Foundation

struct PaginationInfoDTO: Decodable, Equatable, Sendable {
	let count: Int
	let pages: Int
	let next: String?
	let prev: String?
}

struct CharactersResponseDTO: Decodable, Equatable, Sendable {
	let info: PaginationInfoDTO
	let results: [CharacterDTO]
}
