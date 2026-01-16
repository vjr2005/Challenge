import Foundation

@testable import ChallengeCharacter

extension CharacterDTO {
	static func stub(
		id: Int = 1,
		name: String = "Rick Sanchez",
		status: String = "Alive",
		species: String = "Human",
		type: String = "",
		gender: String = "Male",
		origin: LocationDTO = .stub(name: "Earth (C-137)"),
		location: LocationDTO = .stub(name: "Citadel of Ricks", url: "https://rickandmortyapi.com/api/location/3"),
		image: String = "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
		episode: [String] = ["https://rickandmortyapi.com/api/episode/1"],
		url: String = "https://rickandmortyapi.com/api/character/1",
		created: String = "2017-11-04T18:48:46.250Z"
	) -> CharacterDTO {
		CharacterDTO(
			id: id,
			name: name,
			status: status,
			species: species,
			type: type,
			gender: gender,
			origin: origin,
			location: location,
			image: image,
			episode: episode,
			url: url,
			created: created
		)
	}

	static func stubJSONData() -> Data {
		Data("""
		{
			"id": 1,
			"name": "Rick Sanchez",
			"status": "Alive",
			"species": "Human",
			"type": "",
			"gender": "Male",
			"origin": {"name": "Earth (C-137)", "url": "https://rickandmortyapi.com/api/location/1"},
			"location": {"name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3"},
			"image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
			"episode": ["https://rickandmortyapi.com/api/episode/1"],
			"url": "https://rickandmortyapi.com/api/character/1",
			"created": "2017-11-04T18:48:46.250Z"
		}
		""".utf8)
	}
}
