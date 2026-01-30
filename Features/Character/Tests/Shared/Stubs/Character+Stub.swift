import Foundation

@testable import ChallengeCharacter

extension Character {
	static func stub(
		id: Int = 1,
		name: String = "Rick Sanchez",
		status: CharacterStatus = .alive,
		species: String = "Human",
		gender: CharacterGender = .male,
		origin: Location = .stub(name: "Earth (C-137)"),
		location: Location = .stub(name: "Citadel of Ricks", url: URL(string: "https://rickandmortyapi.com/api/location/3")),
		imageURL: URL? = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
	) -> Character {
		Character(
			id: id,
			name: name,
			status: status,
			species: species,
			gender: gender,
			origin: origin,
			location: location,
			imageURL: imageURL
		)
	}
}
