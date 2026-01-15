import Foundation

/// Domain model representing a character.
struct Character: Equatable, Hashable {
	let id: Int
	let name: String
	let status: CharacterStatus
	let species: String
	let gender: String
	let origin: Location
	let location: Location
	let imageURL: URL?
}

/// Character life status.
enum CharacterStatus: String {
	case alive = "Alive"
	case dead = "Dead"
	case unknown

	init(from string: String) {
		self = Self(rawValue: string) ?? .unknown
	}
}
