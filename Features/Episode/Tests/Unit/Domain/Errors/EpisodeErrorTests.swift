import Foundation
import Testing

@testable import ChallengeEpisode

struct EpisodeErrorTests {
	// MARK: - Equatability

	@Test(arguments: [
		(EpisodeError.loadFailed(), EpisodeError.loadFailed(), true),
		(EpisodeError.notFound(identifier: 1), EpisodeError.notFound(identifier: 1), true),
		(EpisodeError.notFound(identifier: 1), EpisodeError.notFound(identifier: 2), false),
		(EpisodeError.loadFailed(), EpisodeError.notFound(identifier: 1), false)
	])
	func equality(
		lhs: EpisodeError,
		rhs: EpisodeError,
		expectedEqual: Bool
	) {
		// When
		let areEqual = lhs == rhs

		// Then
		#expect(areEqual == expectedEqual)
	}

	// MARK: - LocalizedError

	@Test("Load failed error description is localized")
	func loadFailedErrorDescriptionIsLocalized() {
		// Given
		let sut = EpisodeError.loadFailed()

		// When
		let description = sut.errorDescription

		// Then
		#expect(description != nil)
		#expect(description?.isEmpty == false)
	}

	@Test("Not found error description contains id")
	func notFoundErrorDescriptionContainsId() {
		// Given
		let sut = EpisodeError.notFound(identifier: 42)

		// When
		let description = sut.errorDescription

		// Then
		#expect(description != nil)
		#expect(description?.contains("42") == true)
	}

	// MARK: - CustomDebugStringConvertible

	@Test("Load failed debugDescription returns the original error description")
	func loadFailedDebugDescriptionReturnsDescription() {
		// Given
		let sut = EpisodeError.loadFailed(description: "dataCorrupted: test")

		// When
		let result = sut.debugDescription

		// Then
		#expect(result == "dataCorrupted: test")
	}

	@Test("Load failed debugDescription returns empty string when no description")
	func loadFailedDebugDescriptionReturnsEmptyByDefault() {
		// Given
		let sut = EpisodeError.loadFailed()

		// When
		let result = sut.debugDescription

		// Then
		#expect(result == "")
	}

	@Test("Not found debugDescription contains identifier")
	func notFoundDebugDescriptionContainsIdentifier() {
		// Given
		let sut = EpisodeError.notFound(identifier: 42)

		// When
		let result = sut.debugDescription

		// Then
		#expect(result.contains("42"))
	}

	// MARK: - Equatable ignores description

	@Test("Two loadFailed with different descriptions are equal")
	func loadFailedWithDifferentDescriptionsAreEqual() {
		// Given
		let lhs = EpisodeError.loadFailed(description: "error A")
		let rhs = EpisodeError.loadFailed(description: "error B")

		// When
		let areEqual = lhs == rhs

		// Then
		#expect(areEqual)
	}

	// MARK: - Sendable

	@Test("Error is Sendable across contexts")
	func errorIsSendable() async {
		// Given
		let error = EpisodeError.loadFailed()

		// When
		let sentError = await sendToAnotherContext(error)

		// Then
		#expect(sentError == error)
	}
}

// MARK: - Helpers

private func sendToAnotherContext(_ error: EpisodeError) async -> EpisodeError {
	await Task { error }.value
}
