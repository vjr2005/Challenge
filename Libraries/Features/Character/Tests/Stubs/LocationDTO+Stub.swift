import Foundation

@testable import ChallengeCharacter

extension LocationDTO {
	static func stub(
		name: String = "Earth (C-137)",
		url: String = "https://rickandmortyapi.com/api/location/1",
	) -> LocationDTO {
		LocationDTO(
			name: name,
			url: url
		)
	}
}
