import Foundation
import Testing

@testable import ChallengeNetworking

struct GraphQLResponseErrorTests {
	// MARK: - Decoding

	@Test("Decodes error with all fields")
	func decodesErrorWithAllFields() throws {
		// Given
		let json = """
		{
			"message": "Cannot query field",
			"locations": [{"line": 1, "column": 3}],
			"path": ["episodes", "results"]
		}
		"""

		// When
		let sut = try JSONDecoder().decode(GraphQLResponseError.self, from: Data(json.utf8))

		// Then
		#expect(sut.message == "Cannot query field")
		#expect(sut.locations?.count == 1)
		#expect(sut.locations?.first?.line == 1)
		#expect(sut.locations?.first?.column == 3)
		#expect(sut.path == ["episodes", "results"])
	}

	@Test("Decodes error with message only")
	func decodesErrorWithMessageOnly() throws {
		// Given
		let json = """
		{
			"message": "Internal server error"
		}
		"""

		// When
		let sut = try JSONDecoder().decode(GraphQLResponseError.self, from: Data(json.utf8))

		// Then
		#expect(sut.message == "Internal server error")
		#expect(sut.locations == nil)
		#expect(sut.path == nil)
	}

	@Test("Decodes error with multiple locations")
	func decodesErrorWithMultipleLocations() throws {
		// Given
		let json = """
		{
			"message": "Syntax error",
			"locations": [
				{"line": 1, "column": 1},
				{"line": 2, "column": 5}
			]
		}
		"""

		// When
		let sut = try JSONDecoder().decode(GraphQLResponseError.self, from: Data(json.utf8))

		// Then
		#expect(sut.locations?.count == 2)
		#expect(sut.locations?[0] == GraphQLResponseError.Location(line: 1, column: 1))
		#expect(sut.locations?[1] == GraphQLResponseError.Location(line: 2, column: 5))
	}

	// MARK: - Equatable

	@Test("Errors with same values are equal")
	func errorsWithSameValuesAreEqual() {
		// Given
		let lhs = GraphQLResponseError(
			message: "Error",
			locations: [GraphQLResponseError.Location(line: 1, column: 1)],
			path: ["field"]
		)
		let rhs = GraphQLResponseError(
			message: "Error",
			locations: [GraphQLResponseError.Location(line: 1, column: 1)],
			path: ["field"]
		)

		// Then
		#expect(lhs == rhs)
	}

	@Test("Errors with different messages are not equal")
	func errorsWithDifferentMessagesAreNotEqual() {
		// Given
		let lhs = GraphQLResponseError(message: "Error 1", locations: nil, path: nil)
		let rhs = GraphQLResponseError(message: "Error 2", locations: nil, path: nil)

		// Then
		#expect(lhs != rhs)
	}
}
