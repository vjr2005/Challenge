import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeNetworking

@Suite(.timeLimit(.minutes(1)))
struct HTTPTransportMockTests {
	// MARK: - Properties

	private let testURL: URL
	private let sut: HTTPTransportMock

	// MARK: - Initialization

	init() throws {
		testURL = try #require(URL(string: "https://test.example.com/api"))
		sut = HTTPTransportMock()
	}

	// MARK: - Tests

	@Test("Returns configured success result")
	func returnsConfiguredSuccessResult() async throws {
		// Given
		let expectedData = Data("{\"id\":1}".utf8)
		let expectedResponse = try #require(HTTPURLResponse(
			url: testURL,
			statusCode: 200,
			httpVersion: "HTTP/1.1",
			headerFields: nil
		))
		await sut.setResult(.success((expectedData, expectedResponse)))
		let request = URLRequest(url: testURL)

		// When
		let (data, response) = try await sut.send(request)

		// Then
		#expect(data == expectedData)
		#expect(response.statusCode == 200)
	}

	@Test("Returns configured failure result")
	func returnsConfiguredFailureResult() async throws {
		// Given
		let expectedError = URLError(.badServerResponse)
		await sut.setResult(.failure(expectedError))
		let request = URLRequest(url: testURL)

		// When / Then
		await #expect {
			_ = try await sut.send(request)
		} throws: { error in
			(error as? URLError)?.code == .badServerResponse
		}
	}

	@Test("Records sent requests")
	func recordsSentRequests() async throws {
		// Given
		let request1 = URLRequest(url: testURL)
		let request2 = URLRequest(url: try #require(URL(string: "https://test.example.com/other")))

		// When
		_ = try await sut.send(request1)
		_ = try await sut.send(request2)

		// Then
		let sentRequests = await sut.sentRequests
		#expect(sentRequests.count == 2)
		#expect(sentRequests[0].url == testURL)
		#expect(sentRequests[1].url?.absoluteString == "https://test.example.com/other")
	}
}
