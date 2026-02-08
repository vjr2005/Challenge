import ChallengeNetworking
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterErrorMapperTests {
	// MARK: - Properties

	private let sut = CharacterErrorMapper()

	// MARK: - HTTP Error Tests

	@Test("Maps HTTP 404 to notFound error with correct identifier")
	func mapsHTTP404ToNotFound() {
		// Given
		let input = CharacterErrorMapperInput(
			error: HTTPError.statusCode(404, Data()),
			identifier: 42
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .notFound(identifier: 42))
	}

	@Test("Maps HTTP 500 to loadFailed error")
	func mapsHTTP500ToLoadFailed() {
		// Given
		let input = CharacterErrorMapperInput(
			error: HTTPError.statusCode(500, Data()),
			identifier: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed)
	}

	@Test("Maps invalidURL to loadFailed error")
	func mapsInvalidURLToLoadFailed() {
		// Given
		let input = CharacterErrorMapperInput(
			error: HTTPError.invalidURL,
			identifier: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed)
	}

	@Test("Maps invalidResponse to loadFailed error")
	func mapsInvalidResponseToLoadFailed() {
		// Given
		let input = CharacterErrorMapperInput(
			error: HTTPError.invalidResponse,
			identifier: 1
		)

		// When
		let result = sut.map(input)

		// Then
		#expect(result == .loadFailed)
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
		#expect(result == .loadFailed)
	}
}

// MARK: - Private

private enum GenericTestError: Error {
	case unknown
}
