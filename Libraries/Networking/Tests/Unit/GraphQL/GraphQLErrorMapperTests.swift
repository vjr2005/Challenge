import Foundation
import Testing

@testable import ChallengeNetworking

struct GraphQLErrorMapperTests {
	private let sut = GraphQLErrorMapper()

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

	@Test("Maps response errors to invalidResponse")
	func mapsResponseErrorsToInvalidResponse() {
		// Given
		let errors = [GraphQLResponseError(message: "Error", locations: nil, path: nil)]

		// When
		let result = sut.map(.response(errors))

		// Then
		#expect(result == .invalidResponse)
	}

	@Test("Maps decodingFailed to decodingFailed")
	func mapsDecodingFailedToDecodingFailed() {
		// When
		let result = sut.map(.decodingFailed(description: "test error"))

		// Then
		#expect(result == .decodingFailed(description: "test error"))
	}

	@Test("Maps invalidResponse to invalidResponse")
	func mapsInvalidResponseToInvalidResponse() {
		// When
		let result = sut.map(.invalidResponse)

		// Then
		#expect(result == .invalidResponse)
	}
}
