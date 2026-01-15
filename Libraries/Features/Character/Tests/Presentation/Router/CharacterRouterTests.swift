import Foundation
import Testing

@testable import ChallengeCharacter

@MainActor
struct CharacterRouterTests {
	@Test
	func initialPathIsEmpty() {
		// Given
		let sut = CharacterRouter()

		// Then
		#expect(sut.path.isEmpty)
	}

	@Test
	func navigateAddsDestinationToPath() {
		// Given
		let sut = CharacterRouter()

		// When
		sut.navigate(to: .detail(.stub()))

		// Then
		#expect(sut.path.count == 1)
	}

	@Test
	func popRemovesLastDestination() {
		// Given
		let sut = CharacterRouter()
		sut.navigate(to: .detail(.stub()))

		// When
		sut.pop()

		// Then
		#expect(sut.path.isEmpty)
	}

	@Test
	func popDoesNothingWhenPathIsEmpty() {
		// Given
		let sut = CharacterRouter()

		// When
		sut.pop()

		// Then
		#expect(sut.path.isEmpty)
	}

	@Test
	func popToRootRemovesAllDestinations() {
		// Given
		let sut = CharacterRouter()
		sut.navigate(to: .detail(.stub()))
		sut.navigate(to: .detail(.stub()))

		// When
		sut.popToRoot()

		// Then
		#expect(sut.path.isEmpty)
	}
}
