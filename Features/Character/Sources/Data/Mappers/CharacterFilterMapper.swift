import ChallengeCore
import Foundation

struct CharacterFilterMapper: MapperContract {
	func map(_ input: CharacterFilter) -> CharacterFilterDTO {
		CharacterFilterDTO(
			name: input.name,
			status: input.status?.rawValue.lowercased(),
			species: input.species,
			type: input.type,
			gender: input.gender?.rawValue.lowercased()
		)
	}
}
