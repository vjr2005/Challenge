import Foundation

/// DTO for character data from the Rick and Morty API.
struct CharacterDTO: Decodable, Equatable, Sendable {
	let id: Int
	let name: String
	let status: String
	let species: String
	let type: String
	let gender: String
	let origin: LocationDTO
	let location: LocationDTO
	let image: String
	let episode: [String]
	let url: String
	let created: String
}
