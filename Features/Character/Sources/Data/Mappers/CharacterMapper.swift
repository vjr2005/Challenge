import ChallengeCore
import Foundation

struct CharacterMapper: MapperContract {
	private let locationMapper = LocationMapper()

	func map(_ input: CharacterDTO) -> Character {
		Character(
			id: input.id,
			name: input.name,
			status: CharacterStatus(from: input.status),
			species: input.species,
			gender: CharacterGender(from: input.gender),
			origin: locationMapper.map(input.origin),
			location: locationMapper.map(input.location),
			imageURL: URL(string: input.image)
		)
	}
}
