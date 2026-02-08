import ChallengeNetworking
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharactersPageErrorMapperTests {
	// MARK: - Properties

	private let sut = CharactersPageErrorMapper()

	// MARK: - HTTP Error Tests

	@Test("Maps HTTP 404 to invalidPage error with correct page")
	func mapsHTTP404ToInvalidPage() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: HTTPError.statusCode(404, Data()),
			page: 5
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .invalidPage(page: 5))
	}

	@Test("Maps HTTP 500 to loadFailed error")
	func mapsHTTP500ToLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: HTTPError.statusCode(500, Data()),
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps invalidURL to loadFailed error")
	func mapsInvalidURLToLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: HTTPError.invalidURL,
			page: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed())
	}

	@Test("Maps invalidResponse to loadFailed error")
	func mapsInvalidResponseToLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: HTTPError.invalidResponse,
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

	@Test("Maps HTTP error description into loadFailed")
	func mapsHTTPErrorDescriptionIntoLoadFailed() {
		// Given
		let input = CharactersPageErrorMapperInput(
			error: HTTPError.statusCode(500, Data()),
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
