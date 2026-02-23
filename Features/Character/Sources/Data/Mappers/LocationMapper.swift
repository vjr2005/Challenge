import ChallengeCore
import Foundation

nonisolated struct LocationMapper: MapperContract {
	func map(_ input: LocationDTO) -> Location {
		Location(name: input.name)
	}
}
