import Foundation

@testable import ChallengeCharacter

extension Location {
	static func stub(
		name: String = "Earth (C-137)",
		url: URL? = URL(string: "https://rickandmortyapi.com/api/location/1"),
	) -> Location {
		Location(
			name: name,
			url: url
		)
	}
}
