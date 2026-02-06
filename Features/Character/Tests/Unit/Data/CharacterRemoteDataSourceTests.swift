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
        _ = try await sut.fetchCharacters(page: 1, filter: .empty)

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
        _ = try await sut.fetchCharacters(page: 5, filter: .empty)

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
        _ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(name: "Rick"))

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
        _ = try await sut.fetchCharacters(page: 1, filter: .empty)

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
        _ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(name: ""))

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let nameItem = endpoint.queryItems?.first { $0.name == "name" }
        #expect(nameItem == nil)
    }

    @Test("Fetch characters includes status query parameter when provided")
    func fetchCharactersIncludesStatusQueryParameter() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(status: .alive))

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let statusItem = try #require(endpoint.queryItems?.first { $0.name == "status" })
        #expect(statusItem.value == "alive")
    }

    @Test("Fetch characters includes species query parameter when provided")
    func fetchCharactersIncludesSpeciesQueryParameter() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(species: "Human"))

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let speciesItem = try #require(endpoint.queryItems?.first { $0.name == "species" })
        #expect(speciesItem.value == "Human")
    }

    @Test("Fetch characters includes type query parameter when provided")
    func fetchCharactersIncludesTypeQueryParameter() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(type: "Parasite"))

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let typeItem = try #require(endpoint.queryItems?.first { $0.name == "type" })
        #expect(typeItem.value == "Parasite")
    }

    @Test("Fetch characters includes gender query parameter when provided")
    func fetchCharactersIncludesGenderQueryParameter() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        _ = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(gender: .female))

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let genderItem = try #require(endpoint.queryItems?.first { $0.name == "gender" })
        #expect(genderItem.value == "female")
    }

    @Test("Fetch characters includes all filter parameters when provided")
    func fetchCharactersIncludesAllFilterParameters() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)
        let filter = CharacterFilter(
            name: "Rick",
            status: .alive,
            species: "Human",
            type: "Scientist",
            gender: .male
        )

        // When
        _ = try await sut.fetchCharacters(page: 1, filter: filter)

        // Then
        let endpoint = try #require(httpClientMock.requestedEndpoints.first)
        let queryItems = try #require(endpoint.queryItems)
        #expect(queryItems.contains { $0.name == "page" && $0.value == "1" })
        #expect(queryItems.contains { $0.name == "name" && $0.value == "Rick" })
        #expect(queryItems.contains { $0.name == "status" && $0.value == "alive" })
        #expect(queryItems.contains { $0.name == "species" && $0.value == "Human" })
        #expect(queryItems.contains { $0.name == "type" && $0.value == "Scientist" })
        #expect(queryItems.contains { $0.name == "gender" && $0.value == "male" })
    }

    @Test("Fetch characters decodes response correctly")
    func fetchCharactersDecodesResponseCorrectly() async throws {
        // Given
        let jsonData = try loadJSONData("characters_response")
        httpClientMock.result = .success(jsonData)

        // When
        let value = try await sut.fetchCharacters(page: 1, filter: .empty)

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
            _ = try await sut.fetchCharacters(page: 1, filter: .empty)
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
