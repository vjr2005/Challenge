import ChallengeNetworking
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharactersPageErrorMapperTests {
	// MARK: - Properties

	private let sut = CharactersPageErrorMapper()

	// MARK: - API Error Tests

	@Test("Maps APIError.notFound to invalidPage error with correct page")
	func mapsNotFoundToInvalidPage() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: APIError.notFound,
			page: 5
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .invalidPage(page: 5))
	}

	@Test("Maps APIError.serverError to loadFailed error")
	func mapsServerErrorToLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: APIError.serverError(statusCode: 500),
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps APIError.invalidRequest to loadFailed error")
	func mapsInvalidRequestToLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: APIError.invalidRequest,
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps APIError.invalidResponse to loadFailed error")
	func mapsInvalidResponseToLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: APIError.invalidResponse,
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps APIError.decodingFailed to loadFailed error")
	func mapsDecodingFailedToLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: APIError.decodingFailed(description: "test"),
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps DecodingError to loadFailed error")
	func mapsDecodingErrorToLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test")),
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	// MARK: - Description Propagation

	@Test("Maps API error description into loadFailed")
	func mapsAPIErrorDescriptionIntoLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: APIError.serverError(statusCode: 500),
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		if case .loadFailed(let description) = result {
			#expect(description.contains("500"))
		} else {
			Issue.record("Expected loadFailed, got \(result)")
		}
	}

	@Test("Maps DecodingError description into loadFailed")
	func mapsDecodingErrorDescriptionIntoLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "corrupted data")),
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		if case .loadFailed(let description) = result {
			#expect(!description.isEmpty)
		} else {
			Issue.record("Expected loadFailed, got \(result)")
		}
	}

	// MARK: - Generic Error Tests

	@Test("Maps generic error to loadFailed error")
	func mapsGenericErrorToLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: GenericTestError.unknown,
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}
}

// MARK: - Private

private enum GenericTestError: Error {
	case unknown
}
