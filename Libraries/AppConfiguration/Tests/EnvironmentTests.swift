import Testing

@testable import ChallengeAppConfiguration

struct EnvironmentTests {
	// MARK: - current

	@Test
	func currentReturnsValidEnvironment() {
		// Given
		let validEnvironments: [Environment] = [.development, .staging, .production]

		// When
		let current = Environment.current

		// Then
		#expect(validEnvironments.contains(current))
	}

	// MARK: - isDebug

	@Test
	func isDebugReturnsTrueForDevelopment() {
		// Given
		let sut = Environment.development

		// When
		let value = sut.isDebug

		// Then
		#expect(value == true)
	}

	@Test(arguments: [Environment.staging, Environment.production])
	func isDebugReturnsFalseForNonDevelopment(_ environment: Environment) {
		// Given
		let sut = environment

		// When
		let value = sut.isDebug

		// Then
		#expect(value == false)
	}

	// MARK: - isRelease

	@Test
	func isReleaseReturnsTrueForProduction() {
		// Given
		let sut = Environment.production

		// When
		let value = sut.isRelease

		// Then
		#expect(value == true)
	}

	@Test(arguments: [Environment.development, Environment.staging])
	func isReleaseReturnsFalseForNonProduction(_ environment: Environment) {
		// Given
		let sut = environment

		// When
		let value = sut.isRelease

		// Then
		#expect(value == false)
	}

	// MARK: - rickAndMorty API

	@Test(arguments: [Environment.development, Environment.staging, Environment.production])
	func rickAndMortyReturnsValidURL(_ environment: Environment) {
		// Given
		let sut = environment

		// When
		let api = sut.rickAndMorty

		// Then
		#expect(api.baseURL.scheme == "https")
		#expect(api.baseURL.host == "rickandmortyapi.com")
		#expect(api.baseURL.path == "/api")
	}

	@Test
	func rickAndMortyReturnsExpectedURLForDevelopment() {
		// Given
		let sut = Environment.development
		let expected = "https://rickandmortyapi.com/api"

		// When
		let api = sut.rickAndMorty

		// Then
		#expect(api.baseURL.absoluteString == expected)
	}

	@Test
	func rickAndMortyReturnsExpectedURLForStaging() {
		// Given
		let sut = Environment.staging
		let expected = "https://rickandmortyapi.com/api"

		// When
		let api = sut.rickAndMorty

		// Then
		#expect(api.baseURL.absoluteString == expected)
	}

	@Test
	func rickAndMortyReturnsExpectedURLForProduction() {
		// Given
		let sut = Environment.production
		let expected = "https://rickandmortyapi.com/api"

		// When
		let api = sut.rickAndMorty

		// Then
		#expect(api.baseURL.absoluteString == expected)
	}
}
