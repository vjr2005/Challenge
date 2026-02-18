import Foundation

nonisolated struct Location: Equatable, Hashable {
	let name: String
	let url: URL?
}
