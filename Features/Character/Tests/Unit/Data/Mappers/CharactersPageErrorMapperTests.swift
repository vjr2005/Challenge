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
		#expect(result == .loadFailed)
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
		#expect(result == .loadFailed)
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
		#expect(result == .loadFailed)
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
		#expect(result == .loadFailed)
	}
}

// MARK: - Private

private enum GenericTestError: Error {
	case unknown
}
