import ChallengeCore
import Foundation

nonisolated struct CharactersPageMapperInput {
	let response: CharactersResponseDTO
	let currentPage: Int
}

nonisolated struct CharactersPageMapper: MapperContract {
	private let characterMapper = CharacterMapper()

	func map(_ input: CharactersPageMapperInput) -> CharactersPage {
		CharactersPage(
			characters: input.response.results.map { characterMapper.map($0) },
			currentPage: input.currentPage,
			totalPages: input.response.info.pages,
			totalCount: input.response.info.count,
			hasNextPage: input.response.info.next != nil,
			hasPreviousPage: input.response.info.prev != nil
		)
	}
}
