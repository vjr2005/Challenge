import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct LocationMapperTests {
	// MARK: - Properties

	private let sut = LocationMapper()

	// MARK: - Tests

	@Test("Maps name from LocationDTO to Location")
	func mapsName() {
		// Given
		let dto = LocationDTO(
			name: "Earth (C-137)",
			url: "https://rickandmortyapi.com/api/location/1"
		)
		let expected = Location(name: "Earth (C-137)")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps name from LocationDTO with empty URL")
	func mapsNameWithEmptyURL() {
		// Given
		let dto = LocationDTO(
			name: "unknown",
			url: ""
		)
		let expected = Location(name: "unknown")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}
}
