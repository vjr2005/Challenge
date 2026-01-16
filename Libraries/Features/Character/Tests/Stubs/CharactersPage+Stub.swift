import Foundation

@testable import ChallengeCharacter

extension CharactersPage {
	static func stub(
		characters: [Character] = [.stub()],
		currentPage: Int = 1,
		totalPages: Int = 42,
		totalCount: Int = 826,
		hasNextPage: Bool = true,
		hasPreviousPage: Bool = false
	) -> CharactersPage {
		CharactersPage(
			characters: characters,
			currentPage: currentPage,
			totalPages: totalPages,
			totalCount: totalCount,
			hasNextPage: hasNextPage,
			hasPreviousPage: hasPreviousPage
		)
	}
}
