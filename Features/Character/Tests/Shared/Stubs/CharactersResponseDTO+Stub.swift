@testable import ChallengeCharacter

nonisolated extension CharactersResponseDTO {
	static func stub(
		info: PaginationInfoDTO = .stub(),
		results: [CharacterDTO] = [.stub()]
	) -> CharactersResponseDTO {
		CharactersResponseDTO(
			info: info,
			results: results
		)
	}
}

nonisolated extension PaginationInfoDTO {
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
