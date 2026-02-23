import Foundation

@testable import ChallengeCharacter

extension Location {
	static func stub(
		name: String = "Earth (C-137)"
	) -> Location {
		Location(name: name)
	}
}
