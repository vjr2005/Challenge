import Foundation

struct Character: Equatable, Hashable {
	let id: Int
	let name: String
	let status: CharacterStatus
	let species: String
	let gender: CharacterGender
	let origin: Location
	let location: Location
	let imageURL: URL?
}

enum CharacterStatus: String {
	case alive = "Alive"
	case dead = "Dead"
	case unknown

	init(from string: String) {
		self = Self(rawValue: string) ?? .unknown
	}
}

enum CharacterGender: String {
	case female = "Female"
	case male = "Male"
	case genderless = "Genderless"
	case unknown

	init(from string: String) {
		self = Self(rawValue: string) ?? .unknown
	}
}
