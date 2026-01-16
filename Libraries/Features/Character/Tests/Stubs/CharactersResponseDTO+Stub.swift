import Foundation

@testable import ChallengeCharacter

extension PaginationInfoDTO {
	static func stub(
		count: Int = 826,
		pages: Int = 42,
		next: String? = "https://rickandmortyapi.com/api/character?page=2",
		prev: String? = nil
	) -> PaginationInfoDTO {
		PaginationInfoDTO(
			count: count,
			pages: pages,
			next: next,
			prev: prev
		)
	}
}

extension CharactersResponseDTO {
	static func stub(
		info: PaginationInfoDTO = .stub(),
		results: [CharacterDTO] = [.stub()]
	) -> CharactersResponseDTO {
		CharactersResponseDTO(
			info: info,
			results: results
		)
	}

	static func stubJSONData(page: Int = 1) -> Data {
		let next = page < 42 ? "\"https://rickandmortyapi.com/api/character?page=\(page + 1)\"" : "null"
		let prev = page > 1 ? "\"https://rickandmortyapi.com/api/character?page=\(page - 1)\"" : "null"

		return Data("""
		{
			"info": {
				"count": 826,
				"pages": 42,
				"next": \(next),
				"prev": \(prev)
			},
			"results": [
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
			]
		}
		""".utf8)
	}
}
