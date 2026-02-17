import Foundation
import SwiftData

@Model
nonisolated final class CharactersPageEntity {
	@Attribute(.unique) var page: Int
	var count: Int
	var pages: Int
	var next: String?
	var prev: String?

	@Relationship(deleteRule: .nullify, inverse: \CharacterEntity.page)
	var characters: [CharacterEntity]

	init(
		page: Int,
		count: Int,
		pages: Int,
		next: String?,
		prev: String?,
		characters: [CharacterEntity]
	) {
		self.page = page
		self.count = count
		self.pages = pages
		self.next = next
		self.prev = prev
		self.characters = characters
	}
}
