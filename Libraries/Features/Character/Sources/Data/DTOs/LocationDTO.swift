import Foundation

/// DTO for location data from the Rick and Morty API.
nonisolated struct LocationDTO: Decodable, Equatable {
	let name: String
	let url: String
}
