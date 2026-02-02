import Foundation
import Testing

@testable import ChallengeNetworking

@Suite(.timeLimit(.minutes(1)))
struct URLSessionTransportTests {
	// MARK: - Properties

	private let testURL: URL
	private let session: URLSession
	private let sut: URLSessionTransport

	// MARK: - Initialization

	init() throws {
		testURL = try #require(URL(string: "https://test.example.com/api"))
		session = URLSession.mockSession()
		sut = URLSessionTransport(session: session)
	}

	// MARK: - Tests

	@Test("Returns data and HTTP response on successful request")
	func returnsDataAndResponseOnSuccess() async throws {
		// Given
		let expectedData = Data("{\"id\":1}".utf8)
		let request = URLRequest(url: testURL)
		let expectedURL = testURL

		URLProtocolMock.setHandler({ _ in
			guard let response = HTTPURLResponse(
				url: expectedURL,
				statusCode: 200,
				httpVersion: "HTTP/1.1",
				headerFields: nil
			) else {
				throw URLError(.badServerResponse)
			}
			return (response, expectedData)
		}, forURL: testURL)

		// When
		let (data, response) = try await sut.send(request)

		// Then
		#expect(data == expectedData)
		#expect(response.statusCode == 200)
	}

	@Test("Throws invalid response error when response is not HTTPURLResponse")
	func throwsInvalidResponseWhenNotHTTP() async throws {
		// Given
		let customURL = try #require(URL(string: "custom://test.example.com/api"))
		let customSession = URLSession.mockSession()
		let customSut = URLSessionTransport(session: customSession)
		let request = URLRequest(url: customURL)

		URLProtocolMock.setHandler({ _ in
			let response = URLResponse(
				url: customURL,
				mimeType: nil,
				expectedContentLength: 0,
				textEncodingName: nil
			)
			return (response, Data())
		}, forURL: customURL)

		// When / Then
		await #expect(throws: HTTPTransportError.invalidResponse) {
			_ = try await customSut.send(request)
		}
	}

	@Test("Propagates network errors from URLSession")
	func propagatesNetworkErrors() async throws {
		// Given
		let request = URLRequest(url: testURL)

		URLProtocolMock.setHandler({ _ in
			throw URLError(.notConnectedToInternet)
		}, forURL: testURL)

		// When / Then
		await #expect {
			_ = try await sut.send(request)
		} throws: { error in
			(error as? URLError)?.code == .notConnectedToInternet
		}
	}
}
