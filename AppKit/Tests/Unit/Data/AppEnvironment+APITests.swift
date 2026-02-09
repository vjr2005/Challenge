import ChallengeCore
import Testing

@testable import ChallengeAppKit

struct AppEnvironmentAPITests {
	// MARK: - rickAndMorty API

	@Test(arguments: [AppEnvironment.development, AppEnvironment.staging, AppEnvironment.production])
	func rickAndMortyReturnsValidURL(_ environment: AppEnvironment) {
		// Given
		let sut = environment

		// When
		let api = sut.rickAndMorty

		// Then
		#expect(api.baseURL.scheme == "https")
		#expect(api.baseURL.host == "rickandmortyapi.com")
		#expect(api.baseURL.path == "")
	}

	@Test("Rick and Morty API returns expected URL for development environment")
	func rickAndMortyReturnsExpectedURLForDevelopment() {
		// Given
		let sut = AppEnvironment.development
		let expected = "https://rickandmortyapi.com"

		// When
		let api = sut.rickAndMorty

		// Then
		#expect(api.baseURL.absoluteString == expected)
	}

	@Test("Rick and Morty API returns expected URL for staging environment")
	func rickAndMortyReturnsExpectedURLForStaging() {
		// Given
		let sut = AppEnvironment.staging
		let expected = "https://rickandmortyapi.com"

		// When
		let api = sut.rickAndMorty

		// Then
		#expect(api.baseURL.absoluteString == expected)
	}

	@Test("Rick and Morty API returns expected URL for production environment")
	func rickAndMortyReturnsExpectedURLForProduction() {
		// Given
		let sut = AppEnvironment.production
		let expected = "https://rickandmortyapi.com"

		// When
		let api = sut.rickAndMorty

		// Then
		#expect(api.baseURL.absoluteString == expected)
	}
}
