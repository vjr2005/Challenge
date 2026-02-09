import Foundation
import Testing

@testable import ChallengeNetworking

struct GraphQLErrorTests {
	@Test(arguments: [
		(GraphQLError.invalidResponse, GraphQLError.invalidResponse, true),
		(GraphQLError.statusCode(404, Data()), GraphQLError.statusCode(404, Data()), true),
		(GraphQLError.statusCode(404, Data()), GraphQLError.statusCode(500, Data()), false),
		(GraphQLError.invalidResponse, GraphQLError.statusCode(404, Data()), false)
	])
	func equality(lhs: GraphQLError, rhs: GraphQLError, expectedEqual: Bool) {
		// When
		let areEqual = lhs == rhs

		// Then
		#expect(areEqual == expectedEqual)
	}

	@Test("Response errors with same errors are equal")
	func responseErrorsEquality() {
		// Given
		let errors = [GraphQLResponseError(message: "Error", locations: nil, path: nil)]
		let lhs = GraphQLError.response(errors)
		let rhs = GraphQLError.response(errors)

		// Then
		#expect(lhs == rhs)
	}

	@Test("Response errors with different errors are not equal")
	func responseErrorsInequality() {
		// Given
		let lhs = GraphQLError.response([GraphQLResponseError(message: "Error 1", locations: nil, path: nil)])
		let rhs = GraphQLError.response([GraphQLResponseError(message: "Error 2", locations: nil, path: nil)])

		// Then
		#expect(lhs != rhs)
	}

	@Test("Decoding failed errors with same description are equal")
	func decodingFailedEquality() {
		// Given
		let lhs = GraphQLError.decodingFailed(description: "test")
		let rhs = GraphQLError.decodingFailed(description: "test")

		// Then
		#expect(lhs == rhs)
	}

	@Test("Decoding failed errors with different descriptions are not equal")
	func decodingFailedInequality() {
		// Given
		let lhs = GraphQLError.decodingFailed(description: "error1")
		let rhs = GraphQLError.decodingFailed(description: "error2")

		// Then
		#expect(lhs != rhs)
	}
}
