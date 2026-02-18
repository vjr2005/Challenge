import Foundation

nonisolated struct LocationDTO: Decodable, Equatable {
	let name: String
	let url: String
}
