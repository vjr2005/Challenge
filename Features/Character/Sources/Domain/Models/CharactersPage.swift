import Foundation

struct CharactersPage: Equatable {
	let characters: [Character]
	let currentPage: Int
	let totalPages: Int
	let totalCount: Int
	let hasNextPage: Bool
	let hasPreviousPage: Bool
}
