import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterRemoteDataSourceTests {
    // MARK: - Properties

    private let httpClientMock = HTTPClientMock()
    private let sut: CharacterRemoteDataSource

    // MARK: - Initialization

    init() {
        sut = CharacterRemoteDataSource(httpClient: httpClientMock)
    }

    // MARK: - Fetch Character Tests

    @Test("Fetch character uses correct endpoint path")
    func fetchCharacterUsesCorrectEndpoint() async throws {
        // Given
        let jsonData = try loadJSONData("character")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacter(identifier: 1)

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        #expect(endpoint.path == "/character/1")
        #expect(endpoint.method == .get)
    }

    @Test("Fetch character decodes response correctly")
    func fetchCharacterDecodesResponseCorrectly() async throws {
        // Given
        let jsonData = try loadJSONData("character")
        httpClientMock.result = .success(jsonData)

        // When
        let value = try await sut.fetchCharacter(identifier: 1)

        // Then
        #expect(value.id == 1)
        #expect(value.name == "Rick Sanchez")
        #expect(value.status == "Alive")
        #expect(value.species == "Human")
    }

    @Test("Fetch character throws on HTTP error")
    func fetchCharacterThrowsOnHTTPError() async throws {
        // Given
        httpClientMock.result = .failure(TestError.network)

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.fetchCharacter(identifier: 1)
        }
    }

    @Test(arguments: [1, 2, 42, 826])
    func fetchCharacterUsesProvidedId(_ identifier: Int) async throws {
        // Given
        let jsonData = try loadJSONData("character")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacter(identifier: identifier)

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.last)
        #expect(endpoint.path == "/character/\(identifier)")
    }

    // MARK: - Fetch Characters (Paginated)

    @Test("Fetch characters uses correct endpoint path")
    func fetchCharactersUsesCorrectEndpoint() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacters(page: 1, query: nil)

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        #expect(endpoint.path == "/character")
        #expect(endpoint.method == .get)
    }

    @Test("Fetch characters includes page query parameter")
    func fetchCharactersIncludesPageQueryParameter() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacters(page: 5, query: nil)

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let pageItem = try #require(endpoint.queryItems?.first { $0.name == "page" })
        #expect(pageItem.value == "5")
    }

    @Test("Fetch characters includes name query parameter when provided")
    func fetchCharactersIncludesNameQueryParameterWhenProvided() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacters(page: 1, query: "Rick")

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let nameItem = try #require(endpoint.queryItems?.first { $0.name == "name" })
        #expect(nameItem.value == "Rick")
    }

    @Test("Fetch characters omits name query parameter when nil")
    func fetchCharactersOmitsNameQueryParameterWhenNil() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacters(page: 1, query: nil)

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let nameItem = endpoint.queryItems?.first { $0.name == "name" }
        #expect(nameItem == nil)
    }

    @Test("Fetch characters omits name query parameter when empty")
    func fetchCharactersOmitsNameQueryParameterWhenEmpty() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacters(page: 1, query: "")

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let nameItem = endpoint.queryItems?.first { $0.name == "name" }
        #expect(nameItem == nil)
    }

    @Test("Fetch characters decodes response correctly")
    func fetchCharactersDecodesResponseCorrectly() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        let value = try await sut.fetchCharacters(page: 1, query: nil)

        // Then
        #expect(value.info.count == 826)
        #expect(value.info.pages == 42)
        #expect(value.results.count == 1)
        #expect(value.results.first?.name == "Rick Sanchez")
    }

    @Test("Fetch characters throws on HTTP error")
    func fetchCharactersThrowsOnHTTPError() async throws {
        // Given
        httpClientMock.result = .failure(TestError.network)

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.fetchCharacters(page: 1, query: nil)
        }
    }
}

// MARK: - Private

private extension CharacterRemoteDataSourceTests {
    func loadJSONData(_ filename: String) throws -> Data {
        try Bundle.module.loadJSONData(filename)
    }
}

private enum TestError: Error {
    case network
}
