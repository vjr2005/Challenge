import ChallengeNetworking
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeErrorMapperTests {
	// MARK: - Properties

	private let sut = EpisodeErrorMapper()

	// MARK: - API Error Tests

	@Test("Maps APIError.notFound to notFound error with correct identifier")
	func mapsNotFoundToNotFound() {
		// Given
		let input = EpisodeErrorMapperInput(
			error: APIError.notFound,
			characterIdentifier: 42
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
		let input = EpisodeErrorMapperInput(error: error, characterIdentifier: 1)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps DecodingError to loadFailed error")
	func mapsDecodingErrorToLoadFailed() {
		// Given
		let input = EpisodeErrorMapperInput(
			error: DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test")),
			characterIdentifier: 1
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
		let input = EpisodeErrorMapperInput(
			error: APIError.serverError(statusCode: 500),
			characterIdentifier: 1
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
		let input = EpisodeErrorMapperInput(
			error: DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "corrupted data")),
			characterIdentifier: 1
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
		let input = EpisodeErrorMapperInput(
			error: GenericTestError.unknown,
			characterIdentifier: 1
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
