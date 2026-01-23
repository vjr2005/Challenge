import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterRemoteDataSourceTests {
	private let testBundle = Bundle(for: BundleToken.self)

	@Test
	func fetchCharacterUsesCorrectEndpoint() async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("character")
		let httpClientMock = HTTPClientMock(result: .success(jsonData))
		let sut = CharacterRemoteDataSource(httpClient: httpClientMock)

		// When
		_ = try await sut.fetchCharacter(identifier: 1)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		#expect(endpoint.path == "/character/1")
		#expect(endpoint.method == .get)
	}

	@Test
	func fetchCharacterDecodesResponseCorrectly() async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("character")
		let httpClientMock = HTTPClientMock(result: .success(jsonData))
		let sut = CharacterRemoteDataSource(httpClient: httpClientMock)

		// When
		let value = try await sut.fetchCharacter(identifier: 1)

		// Then
		#expect(value.id == 1)
		#expect(value.name == "Rick Sanchez")
		#expect(value.status == "Alive")
		#expect(value.species == "Human")
	}

	@Test
	func fetchCharacterThrowsOnHTTPError() async throws {
		// Given
		let httpClientMock = HTTPClientMock(result: .failure(TestError.network))
		let sut = CharacterRemoteDataSource(httpClient: httpClientMock)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.fetchCharacter(identifier: 1)
		}
	}

	@Test(arguments: [1, 2, 42, 826])
	func fetchCharacterUsesProvidedId(_ identifier: Int) async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("character")
		let httpClientMock = HTTPClientMock(result: .success(jsonData))
		let sut = CharacterRemoteDataSource(httpClient: httpClientMock)

		// When
		_ = try await sut.fetchCharacter(identifier: identifier)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		#expect(endpoint.path == "/character/\(identifier)")
	}

	// MARK: - Fetch Characters (Paginated)

	@Test
	func fetchCharactersUsesCorrectEndpoint() async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("characters_response")
		let httpClientMock = HTTPClientMock(result: .success(jsonData))
		let sut = CharacterRemoteDataSource(httpClient: httpClientMock)

		// When
		_ = try await sut.fetchCharacters(page: 1)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		#expect(endpoint.path == "/character")
		#expect(endpoint.method == .get)
	}

	@Test
	func fetchCharactersIncludesPageQueryParameter() async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("characters_response")
		let httpClientMock = HTTPClientMock(result: .success(jsonData))
		let sut = CharacterRemoteDataSource(httpClient: httpClientMock)

		// When
		_ = try await sut.fetchCharacters(page: 5)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let pageItem = try #require(endpoint.queryItems?.first { $0.name == "page" })
		#expect(pageItem.value == "5")
	}

	@Test
	func fetchCharactersDecodesResponseCorrectly() async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("characters_response")
		let httpClientMock = HTTPClientMock(result: .success(jsonData))
		let sut = CharacterRemoteDataSource(httpClient: httpClientMock)

		// When
		let value = try await sut.fetchCharacters(page: 1)

		// Then
		#expect(value.info.count == 826)
		#expect(value.info.pages == 42)
		#expect(value.results.count == 1)
		#expect(value.results.first?.name == "Rick Sanchez")
	}

	@Test
	func fetchCharactersThrowsOnHTTPError() async throws {
		// Given
		let httpClientMock = HTTPClientMock(result: .failure(TestError.network))
		let sut = CharacterRemoteDataSource(httpClient: httpClientMock)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.fetchCharacters(page: 1)
		}
	}
}

private final class BundleToken {}

private enum TestError: Error {
	case network
}
