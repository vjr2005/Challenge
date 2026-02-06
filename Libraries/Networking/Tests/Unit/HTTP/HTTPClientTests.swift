import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeNetworking

@Suite(.timeLimit(.minutes(1)))
struct HTTPClientTests {
    // MARK: - Tests

    @Test("Builds correct URL from base URL and endpoint path")
    func buildsCorrectURLFromEndpoint() async throws {
        // Given
        let (sut, baseURL) = try makeSUT(host: "test-builds-url")
        let endpoint = Endpoint(path: "/users")
        let expectedBaseURL = baseURL

        URLProtocolMock.setHandler({ request in
            // Then
            #expect(request.url?.absoluteString == "\(expectedBaseURL)/users")
            #expect(request.httpMethod == "GET")
            return (Self.mockResponse(url: request.url), Data())
        }, forURL: baseURL)

        // When
        _ = try await sut.request(endpoint)
    }

    @Test("Includes query items in URL when provided")
    func includesQueryItemsInURL() async throws {
        // Given
        let (sut, baseURL) = try makeSUT(host: "test-query-items")
        let endpoint = Endpoint(
            path: "/users",
            queryItems: [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "limit", value: "20")
            ]
        )

        URLProtocolMock.setHandler({ request in
            // Then
            let urlString = request.url?.absoluteString ?? ""
            #expect(urlString.contains("page=1"))
            #expect(urlString.contains("limit=20"))
            return (Self.mockResponse(url: request.url), Data())
        }, forURL: baseURL)

        // When
        _ = try await sut.request(endpoint)
    }

    @Test("Includes headers in request when provided")
    func includesHeadersInRequest() async throws {
        // Given
        let (sut, baseURL) = try makeSUT(host: "test-headers")
        let endpoint = Endpoint(
            path: "/users",
            headers: [
                "Authorization": "Bearer token123",
                "Content-Type": "application/json"
            ]
        )

        URLProtocolMock.setHandler({ request in
            // Then
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
            return (Self.mockResponse(url: request.url), Data())
        }, forURL: baseURL)

        // When
        _ = try await sut.request(endpoint)
    }

    @Test("Includes body in POST request when provided")
    func includesBodyInRequest() async throws {
        // Given
        let (sut, baseURL) = try makeSUT(host: "test-body")
        let body = Data("{\"name\":\"test\"}".utf8)
        let endpoint = Endpoint(
            path: "/users",
            method: .post,
            body: body
        )

        URLProtocolMock.setHandler({ request in
            // Then
            #expect(request.httpMethod == "POST")
            #expect(request.bodyData == body)
            return (Self.mockResponse(url: request.url), Data())
        }, forURL: baseURL)

        // When
        _ = try await sut.request(endpoint)
    }

    @Test("Returns data on successful response")
    func returnsDataOnSuccess() async throws {
        // Given
        let (sut, baseURL) = try makeSUT(host: "test-returns-data")
        let expectedData = Data("{\"id\":1}".utf8)
        let fallbackURL = baseURL

        URLProtocolMock.setHandler({ request in
            (Self.mockResponse(url: request.url ?? fallbackURL), expectedData)
        }, forURL: baseURL)

        // When
        let data = try await sut.request(Endpoint(path: "/users"))

        // Then
        #expect(data == expectedData)
    }

    @Test("Decodes JSON response to specified type")
    func decodesResponseToType() async throws {
        // Given
        let (sut, baseURL) = try makeSUT(host: "test-decodes-json")
        let responseData = Data("{\"id\":1,\"name\":\"John\"}".utf8)
        let fallbackURL = baseURL

        URLProtocolMock.setHandler({ request in
            (Self.mockResponse(url: request.url ?? fallbackURL), responseData)
        }, forURL: baseURL)

        // When
        let user: TestUser = try await sut.request(Endpoint(path: "/users/1"))

        // Then
        #expect(user.id == 1)
        #expect(user.name == "John")
    }

    @Test(arguments: [400, 401, 403, 404, 500, 502, 503])
    func throwsStatusCodeErrorForHTTPErrors(_ statusCode: Int) async throws {
        // Given
        let (sut, baseURL) = try makeSUT(host: "test-status-\(statusCode)")
        let errorData = Data("Error".utf8)
        let fallbackURL = baseURL

        URLProtocolMock.setHandler({ request in
            (Self.mockResponse(url: request.url ?? fallbackURL, statusCode: statusCode), errorData)
        }, forURL: baseURL)

        // When / Then
        await #expect(throws: HTTPError.statusCode(statusCode, errorData)) {
            _ = try await sut.request(Endpoint(path: "/error"))
        }
    }

    @Test("Throws invalid response error for non-HTTP response")
    func throwsInvalidResponseWhenResponseIsNotHTTPURLResponse() async throws {
        // Given
        // Use custom URL scheme to prevent URLSession from auto-converting to HTTPURLResponse
        let customBaseURL = try #require(URL(string: "custom://test-invalid-response.example.com"))
        let customSut = HTTPClient(baseURL: customBaseURL, session: URLSession.mockSession())

        URLProtocolMock.setHandler({ request in
            let response = URLResponse(
                url: request.url ?? customBaseURL,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            )
            return (response, Data())
        }, forURL: customBaseURL)

        // When / Then
        await #expect(throws: HTTPError.invalidResponse) {
            _ = try await customSut.request(Endpoint(path: "/test"))
        }
    }
}

// MARK: - Private

private struct TestUser: Decodable {
    let id: Int
    let name: String
}

private extension HTTPClientTests {
    func makeSUT(host: String) throws -> (HTTPClient, URL) {
        let baseURL = try #require(URL(string: "https://\(host).example.com"))
        let sut = HTTPClient(baseURL: baseURL, session: URLSession.mockSession())
        return (sut, baseURL)
    }

    static func mockResponse(url: URL?, statusCode: Int = 200) -> HTTPURLResponse {
        guard let url,
            let response = HTTPURLResponse.withStatus(statusCode, url: url)
        else {
            preconditionFailure("Failed to create HTTPURLResponse with status \(statusCode)")
        }
        return response
    }
}
