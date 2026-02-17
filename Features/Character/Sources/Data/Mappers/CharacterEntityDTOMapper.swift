import ChallengeCore
import Foundation

struct CharacterEntityDTOMapper: MapperContract {
	nonisolated func map(_ input: CharacterEntity) -> CharacterDTO {
		CharacterDTO(
			id: input.identifier,
			name: input.name,
			status: input.status,
			species: input.species,
			type: input.type,
			gender: input.gender,
			origin: LocationDTO(name: input.origin.name, url: input.origin.url),
			location: LocationDTO(name: input.location.name, url: input.location.url),
			image: input.image,
			episode: input.episode,
			url: input.url,
			created: input.created
		)
	}
}
