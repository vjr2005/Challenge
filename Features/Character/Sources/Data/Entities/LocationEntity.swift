import Foundation

nonisolated struct LocationEntity: Codable, Hashable, Sendable {
	init(name: String, url: String) {
		self.name = name
		self.url = url
	}

	let name: String
	let url: String
}
