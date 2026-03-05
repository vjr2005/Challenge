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

	@Test("Maps non-notFound APIError to loadFailed error", arguments: [
		APIError.serverError(statusCode: 500),
		APIError.invalidRequest,
		APIError.invalidResponse,
		APIError.decodingFailed(description: "test")
	])
	func mapsAPIErrorToLoadFailed(error: APIError) {
		// Given
		let input = CharacterErrorMapperInput(error: error, identifier: 1)

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
