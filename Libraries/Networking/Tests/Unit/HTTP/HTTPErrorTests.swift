import Foundation
import Testing

@testable import ChallengeNetworking

struct HTTPErrorTests {
	@Test(arguments: [
		(HTTPError.invalidURL, HTTPError.invalidURL, true),
		(HTTPError.invalidResponse, HTTPError.invalidResponse, true),
		(HTTPError.invalidURL, HTTPError.invalidResponse, false)
	])
	func equality(
		lhs: HTTPError,
		rhs: HTTPError,
		expectedEqual: Bool,
	) {
		// When
		let areEqual = lhs == rhs

		// Then
		#expect(areEqual == expectedEqual)
	}

	@Test(arguments: [
		(404, 404, true),
		(404, 500, false),
		(200, 200, true)
	])
	func statusCodeEquality(
		lhsCode: Int,
		rhsCode: Int,
		expectedEqual: Bool,
	) {
		// Given
		let data = Data("test".utf8)
		let lhs = HTTPError.statusCode(lhsCode, data)
		let rhs = HTTPError.statusCode(rhsCode, data)

		// When
		let areEqual = lhs == rhs

		// Then
		#expect(areEqual == expectedEqual)
	}

	@Test("Status code errors with same code but different data are not equal")
	func statusCodeWithDifferentDataAreNotEqual() {
		// Given
		let data1 = Data("error1".utf8)
		let data2 = Data("error2".utf8)
		let lhs = HTTPError.statusCode(404, data1)
		let rhs = HTTPError.statusCode(404, data2)

		// When
		let areEqual = lhs == rhs

		// Then
		#expect(areEqual == false)
	}

	@Test("Status code error preserves code and data values")
	func statusCodePreservesCodeAndData() {
		// Given
		let code = 404
		let data = Data("Not Found".utf8)

		// When
		let sut = HTTPError.statusCode(code, data)

		// Then
		if case let .statusCode(errorCode, errorData) = sut {
			#expect(errorCode == code)
			#expect(errorData == data)
		} else {
			Issue.record("Expected statusCode error")
		}
	}
}
