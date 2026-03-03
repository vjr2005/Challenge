import Foundation

@testable import ChallengeCharacter

nonisolated extension Location {
	static func stub(
		name: String = "Earth (C-137)"
	) -> Location {
		Location(name: name)
	}
}
