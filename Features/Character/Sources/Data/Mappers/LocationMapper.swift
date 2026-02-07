import ChallengeCore
import Foundation

struct LocationMapper: MapperContract {
	func map(_ input: LocationDTO) -> Location {
		Location(
			name: input.name,
			url: URL(string: input.url)
		)
	}
}
