import ChallengeNetworking
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterErrorMapperTests {
	// MARK: - Properties

	private let sut = CharacterErrorMapper()

	// MARK: - API Error Tests

	@Test("Maps APIError.notFound to notFound error with correct identifier")
	func mapsNotFoundToNotFound() {
		// Given
		let input = CharacterErrorMapperInput(
			error: APIError.notFound,
			identifier: 42
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .notFound(identifier: 42))
	}

	@Test("Maps APIError.serverError to loadFailed error")
	func mapsServerErrorToLoadFailed() {
		// Given
		let input = CharacterErrorMapperInput(
			error: APIError.serverError(statusCode: 500),
			identifier: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps APIError.invalidRequest to loadFailed error")
	func mapsInvalidRequestToLoadFailed() {
		// Given
		let input = CharacterErrorMapperInput(
			error: APIError.invalidRequest,
			identifier: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps APIError.invalidResponse to loadFailed error")
	func mapsInvalidResponseToLoadFailed() {
		// Given
		let input = CharacterErrorMapperInput(
			error: APIError.invalidResponse,
			identifier: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps APIError.decodingFailed to loadFailed error")
	func mapsDecodingFailedToLoadFailed() {
		// Given
		let input = CharacterErrorMapperInput(
			error: APIError.decodingFailed(description: "test"),
			identifier: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps DecodingError to loadFailed error")
	func mapsDecodingErrorToLoadFailed() {
		// Given
		let input = CharacterErrorMapperInput(
			error: DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test")),
			identifier: 1
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
		let input = CharacterErrorMapperInput(
			error: APIError.serverError(statusCode: 500),
			identifier: 1
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
		let input = CharacterErrorMapperInput(
			error: DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "corrupted data")),
			identifier: 1
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
		let input = CharacterErrorMapperInput(
			error: GenericTestError.unknown,
			identifier: 1
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
