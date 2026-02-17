import Foundation
import SwiftData

@Model
nonisolated final class CharacterEntity {
	@Attribute(.unique) var identifier: Int
	var name: String
	var status: String
	var species: String
	var type: String
	var gender: String
	var origin: LocationEntity
	var location: LocationEntity
	var image: String
	var episode: [String]
	var url: String
	var created: String
	var page: CharactersPageEntity?

	init(
		identifier: Int,
		name: String,
		status: String,
		species: String,
		type: String,
		gender: String,
		origin: LocationEntity,
		location: LocationEntity,
		image: String,
		episode: [String],
		url: String,
		created: String
	) {
		self.identifier = identifier
		self.name = name
		self.status = status
		self.species = species
		self.type = type
		self.gender = gender
		self.origin = origin
		self.location = location
		self.image = image
		self.episode = episode
		self.url = url
		self.created = created
	}
}
