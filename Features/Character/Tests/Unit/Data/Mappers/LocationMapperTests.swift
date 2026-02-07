import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct LocationMapperTests {
	// MARK: - Properties

	private let sut = LocationMapper()

	// MARK: - Tests

	@Test("Maps name and URL from LocationDTO to Location")
	func mapsNameAndURL() {
		// Given
		let dto = LocationDTO(
			name: "Earth (C-137)",
			url: "https://rickandmortyapi.com/api/location/1"
		)
		let expected = Location(
			name: "Earth (C-137)",
			url: URL(string: "https://rickandmortyapi.com/api/location/1")
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps empty URL string to nil")
	func mapsEmptyURLToNil() {
		// Given
		let dto = LocationDTO(
			name: "unknown",
			url: ""
		)
		let expected = Location(
			name: "unknown",
			url: nil
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}
}
