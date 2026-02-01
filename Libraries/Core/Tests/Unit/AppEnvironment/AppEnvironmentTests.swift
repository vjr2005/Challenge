import Testing

@testable import ChallengeCore

struct AppEnvironmentTests {
	// MARK: - current

	@Test("Current returns a valid environment value")
	func currentReturnsValidEnvironment() {
		// Given
		let validEnvironments: [AppEnvironment] = [.development, .staging, .production]

		// When
		let current = AppEnvironment.current

		// Then
		#expect(validEnvironments.contains(current))
	}

	// MARK: - isDebug

	@Test("isDebug returns true for development environment")
	func isDebugReturnsTrueForDevelopment() {
		// Given
		let sut = AppEnvironment.development

		// When
		let value = sut.isDebug

		// Then
		#expect(value == true)
	}

	@Test(arguments: [AppEnvironment.staging, AppEnvironment.production])
	func isDebugReturnsFalseForNonDevelopment(_ environment: AppEnvironment) {
		// Given
		let sut = environment

		// When
		let value = sut.isDebug

		// Then
		#expect(value == false)
	}

	// MARK: - isRelease

	@Test("isRelease returns true for production environment")
	func isReleaseReturnsTrueForProduction() {
		// Given
		let sut = AppEnvironment.production

		// When
		let value = sut.isRelease

		// Then
		#expect(value == true)
	}

	@Test(arguments: [AppEnvironment.development, AppEnvironment.staging])
	func isReleaseReturnsFalseForNonProduction(_ environment: AppEnvironment) {
		// Given
		let sut = environment

		// When
		let value = sut.isRelease

		// Then
		#expect(value == false)
	}
}
