import Foundation
import Testing

@testable import ChallengeNetworking

@Suite(.timeLimit(.minutes(1)))
struct APIErrorTests {
	@Test(arguments: [
		(APIError.invalidRequest, APIError.invalidRequest, true),
		(APIError.invalidResponse, APIError.invalidResponse, true),
		(APIError.notFound, APIError.notFound, true),
		(APIError.invalidRequest, APIError.invalidResponse, false),
		(APIError.invalidRequest, APIError.notFound, false)
	])
	func equality(lhs: APIError, rhs: APIError, expectedEqual: Bool) {
		// When
		let areEqual = lhs == rhs

		// Then
		#expect(areEqual == expectedEqual)
	}

	@Test(arguments: [
		(500, 500, true),
		(500, 502, false),
		(404, 404, true)
	])
	func serverErrorEquality(lhsCode: Int, rhsCode: Int, expectedEqual: Bool) {
		// Given
		let lhs = APIError.serverError(statusCode: lhsCode)
		let rhs = APIError.serverError(statusCode: rhsCode)

		// When
		let areEqual = lhs == rhs

		// Then
		#expect(areEqual == expectedEqual)
	}

	@Test("Decoding failed errors with same description are equal")
	func decodingFailedEquality() {
		// Given
		let lhs = APIError.decodingFailed(description: "test")
		let rhs = APIError.decodingFailed(description: "test")

		// Then
		#expect(lhs == rhs)
	}

	@Test("Decoding failed errors with different descriptions are not equal")
	func decodingFailedInequality() {
		// Given
		let lhs = APIError.decodingFailed(description: "error1")
		let rhs = APIError.decodingFailed(description: "error2")

		// Then
		#expect(lhs != rhs)
	}

	@Test("Server error preserves status code")
	func serverErrorPreservesStatusCode() {
		// Given
		let code = 503

		// When
		let sut = APIError.serverError(statusCode: code)

		// Then
		if case .serverError(let statusCode) = sut {
			#expect(statusCode == code)
		} else {
			Issue.record("Expected serverError, got \(sut)")
		}
	}
}
