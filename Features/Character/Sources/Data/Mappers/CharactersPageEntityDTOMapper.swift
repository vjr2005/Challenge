import ChallengeCore
import Foundation

struct CharactersPageEntityDTOMapper: MapperContract {
	private let characterEntityDTOMapper = CharacterEntityDTOMapper()

	nonisolated func map(_ input: CharactersPageEntity) -> CharactersResponseDTO {
		CharactersResponseDTO(
			info: PaginationInfoDTO(
				count: input.count,
				pages: input.pages,
				next: input.next,
				prev: input.prev
			),
			results: input.characters
				.sorted { $0.identifier < $1.identifier }
				.map { characterEntityDTOMapper.map($0) }
		)
	}
}
