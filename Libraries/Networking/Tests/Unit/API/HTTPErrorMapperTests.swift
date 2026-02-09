import Foundation
import Testing

@testable import ChallengeNetworking

struct HTTPErrorMapperTests {
	private let sut = HTTPErrorMapper()

	@Test("Maps invalidURL to invalidRequest")
	func mapsInvalidURLToInvalidRequest() {
		// When
		let result = sut.map(.invalidURL)

		// Then
		#expect(result == .invalidRequest)
	}

	@Test("Maps invalidResponse to invalidResponse")
	func mapsInvalidResponseToInvalidResponse() {
		// When
		let result = sut.map(.invalidResponse)

		// Then
		#expect(result == .invalidResponse)
	}

	@Test("Maps statusCode 404 to notFound")
	func mapsStatusCode404ToNotFound() {
		// When
		let result = sut.map(.statusCode(404, Data()))

		// Then
		#expect(result == .notFound)
	}

	@Test("Maps statusCode 500 to serverError")
	func mapsStatusCode500ToServerError() {
		// When
		let result = sut.map(.statusCode(500, Data()))

		// Then
		#expect(result == .serverError(statusCode: 500))
	}
}
