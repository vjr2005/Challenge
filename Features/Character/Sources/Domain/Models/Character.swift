import Foundation

nonisolated struct Character: Equatable, Hashable {
	let id: Int
	let name: String
	let status: CharacterStatus
	let species: String
	let gender: CharacterGender
	let origin: Location
	let location: Location
	let imageURL: URL?
}

nonisolated enum CharacterStatus: String, CaseIterable {
	case alive = "Alive"
	case dead = "Dead"
	case unknown

	init(from string: String) {
		self = Self(rawValue: string) ?? .unknown
	}
}

nonisolated enum CharacterGender: String, CaseIterable {
	case female = "Female"
	case male = "Male"
	case genderless = "Genderless"
	case unknown

	init(from string: String) {
		self = Self(rawValue: string) ?? .unknown
	}
}
