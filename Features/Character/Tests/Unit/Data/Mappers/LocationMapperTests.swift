import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct LocationMapperTests {
	// MARK: - Properties

	private let sut = LocationMapper()

	// MARK: - Tests

	@Test("Maps name from LocationDTO to Location")
	func mapsName() throws {
		// Given
		let dto: LocationDTO = try loadJSON("location")
		let expected = Location.stub()

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps name from LocationDTO with empty URL")
	func mapsNameWithEmptyURL() throws {
		// Given
		let dto: LocationDTO = try loadJSON("location_unknown")
		let expected = Location.stub(name: "unknown")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}
}

// MARK: - Private

private extension LocationMapperTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}
