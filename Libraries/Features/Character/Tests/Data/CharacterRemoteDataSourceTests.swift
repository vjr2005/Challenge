import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterRemoteDataSourceTests {
	@Test
	func fetchCharacterUsesCorrectEndpoint() async throws {
		// Given
		let httpClient = HTTPClientMock(result: .success(makeCharacterData()))
		let sut = CharacterRemoteDataSource(httpClient: httpClient)

		// When
		_ = try await sut.fetchCharacter(identifier: 1)

		// Then
		let endpoint = try #require(httpClient.requestedEndpoints.first)
		#expect(endpoint.path == "/character/1")
		#expect(endpoint.method == .get)
	}

	@Test
	func fetchCharacterDecodesResponseCorrectly() async throws {
		// Given
		let expected = CharacterDTO.stub()
		let httpClient = HTTPClientMock(result: .success(makeCharacterData()))
		let sut = CharacterRemoteDataSource(httpClient: httpClient)

		// When
		let value = try await sut.fetchCharacter(identifier: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func fetchCharacterThrowsOnHTTPError() async throws {
		// Given
		let httpClient = HTTPClientMock(result: .failure(TestError.network))
		let sut = CharacterRemoteDataSource(httpClient: httpClient)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.fetchCharacter(identifier: 1)
		}
	}

	@Test(arguments: [1, 2, 42, 826])
	func fetchCharacterUsesProvidedId(_ identifier: Int) async throws {
		// Given
		let httpClient = HTTPClientMock(result: .success(makeCharacterData(identifier: identifier)))
		let sut = CharacterRemoteDataSource(httpClient: httpClient)

		// When
		_ = try await sut.fetchCharacter(identifier: identifier)

		// Then
		let endpoint = try #require(httpClient.requestedEndpoints.first)
		#expect(endpoint.path == "/character/\(identifier)")
	}
}

private enum TestError: Error {
	case network
}

private extension CharacterRemoteDataSourceTests {
	func makeCharacterData(identifier: Int = 1) -> Data {
		let json = """
		{
			"id": \(identifier),
			"name": "Rick Sanchez",
			"status": "Alive",
			"species": "Human",
			"type": "",
			"gender": "Male",
			"origin": {
				"name": "Earth (C-137)",
				"url": "https://rickandmortyapi.com/api/location/1"
			},
			"location": {
				"name": "Citadel of Ricks",
				"url": "https://rickandmortyapi.com/api/location/3"
			},
			"image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
			"episode": [
				"https://rickandmortyapi.com/api/episode/1"
			],
			"url": "https://rickandmortyapi.com/api/character/1",
			"created": "2017-11-04T18:48:46.250Z"
		}
		"""
		return Data(json.utf8)
	}
}
