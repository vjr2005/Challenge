import Foundation

struct CharactersPage: Equatable {
	let characters: [Character]
	let currentPage: Int
	let totalPages: Int
	let totalCount: Int
	let hasNextPage: Bool
	let hasPreviousPage: Bool

	static func empty(currentPage: Int) -> CharactersPage {
		CharactersPage(
			characters: [],
			currentPage: currentPage,
			totalPages: 0,
			totalCount: 0,
			hasNextPage: false,
			hasPreviousPage: false
		)
	}
}
