import Foundation

/// DTO for location data from the Rick and Morty API.
struct LocationDTO: Decodable, Equatable {
	let name: String
	let url: String
}
