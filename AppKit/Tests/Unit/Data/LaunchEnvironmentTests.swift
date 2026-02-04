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
}
