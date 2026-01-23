import Foundation

/// Domain model representing a location.
struct Location: Equatable, Hashable {
	let name: String
	let url: URL?
}
