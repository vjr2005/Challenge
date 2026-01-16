import Foundation

/// Domain model representing a paginated list of characters.
struct CharactersPage: Equatable {
	let characters: [Character]
	let currentPage: Int
	let totalPages: Int
	let totalCount: Int
	let hasNextPage: Bool
	let hasPreviousPage: Bool
}
