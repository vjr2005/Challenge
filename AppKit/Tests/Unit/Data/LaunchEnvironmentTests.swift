import Foundation
import Testing

@testable import ChallengeAppKit

@Suite("LaunchEnvironment")
struct LaunchEnvironmentTests {
	@Test("API base URL is nil when environment has no API_BASE_URL")
	func apiBaseURLIsNilWithoutEnvironmentVariable() {
		// Given
		let environment: [String: String] = [:]

		// When
		let sut = LaunchEnvironment(environment: environment)

		// Then
		#expect(sut.apiBaseURL == nil)
	}

	@Test("API base URL returns correct URL when API_BASE_URL is set")
	func apiBaseURLReturnsURLWhenSet() {
		// Given
		let environment = ["API_BASE_URL": "http://localhost:8080"]

		// When
		let sut = LaunchEnvironment(environment: environment)

		// Then
		#expect(sut.apiBaseURL == URL(string: "http://localhost:8080"))
	}

	@Test("API base URL is nil when API_BASE_URL is empty")
	func apiBaseURLIsNilWhenEmpty() {
		// Given
		let environment = ["API_BASE_URL": ""]

		// When
		let sut = LaunchEnvironment(environment: environment)

		// Then
		#expect(sut.apiBaseURL == nil)
	}

	@Test("Deep link URL is nil when environment has no DEEP_LINK_URL")
	func deepLinkURLIsNilWithoutEnvironmentVariable() {
		// Given
		let environment: [String: String] = [:]

		// When
		let sut = LaunchEnvironment(environment: environment)

		// Then
		#expect(sut.deepLinkURL == nil)
	}

	@Test("Deep link URL returns correct URL when DEEP_LINK_URL is set")
	func deepLinkURLReturnsURLWhenSet() {
		// Given
		let environment = ["DEEP_LINK_URL": "challenge://character/list"]

		// When
		let sut = LaunchEnvironment(environment: environment)

		// Then
		#expect(sut.deepLinkURL == URL(string: "challenge://character/list"))
	}

	@Test("Deep link URL is nil when DEEP_LINK_URL is empty")
	func deepLinkURLIsNilWhenEmpty() {
		// Given
		let environment = ["DEEP_LINK_URL": ""]

		// When
		let sut = LaunchEnvironment(environment: environment)

		// Then
		#expect(sut.deepLinkURL == nil)
	}
}
