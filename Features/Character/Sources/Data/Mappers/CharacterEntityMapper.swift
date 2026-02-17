import ChallengeCore
import Foundation

struct CharacterEntityMapper: MapperContract {
	nonisolated func map(_ input: CharacterDTO) -> CharacterEntity {
		CharacterEntity(
			identifier: input.id,
			name: input.name,
			status: input.status,
			species: input.species,
			type: input.type,
			gender: input.gender,
			origin: LocationEntity(name: input.origin.name, url: input.origin.url),
			location: LocationEntity(name: input.location.name, url: input.location.url),
			image: input.image,
			episode: input.episode,
			url: input.url,
			created: input.created
		)
	}
}
