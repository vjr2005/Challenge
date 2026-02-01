import Foundation
import Testing

@testable import ChallengeNetworking

struct EndpointTests {
	@Test("Endpoint defaults to GET method when not specified")
	func defaultsToGetMethod() {
		// Given
		let path = "/users"

		// When
		let sut = Endpoint(path: path)

		// Then
		#expect(sut.path == "/users")
		#expect(sut.method == .get)
	}

	@Test("Endpoint stores query items correctly")
	func supportsQueryItems() {
		// Given
		let queryItems = [
			URLQueryItem(name: "page", value: "1"),
			URLQueryItem(name: "limit", value: "20")
		]

		// When
		let sut = Endpoint(path: "/users", queryItems: queryItems)

		// Then
		#expect(sut.queryItems?.count == 2)
		#expect(sut.queryItems?.first?.name == "page")
		#expect(sut.queryItems?.last?.value == "20")
	}

	@Test(arguments: [
		HTTPMethod.get,
		HTTPMethod.post,
		HTTPMethod.put,
		HTTPMethod.patch,
		HTTPMethod.delete
	])
	func supportsHTTPMethod(_ method: HTTPMethod) {
		// Given
		let path = "/test"

		// When
		let sut = Endpoint(path: path, method: method)

		// Then
		#expect(sut.method == method)
		#expect(sut.path == path)
	}

	@Test(arguments: [
		"/users",
		"/posts/123",
		"/api/v1/items"
	])
	func preservesPath(_ path: String) {
		// When
		let sut = Endpoint(path: path)

		// Then
		#expect(sut.path == path)
	}

	@Test("Endpoint has correct default values for all properties")
	func hasCorrectDefaultValues() {
		// When
		let sut = Endpoint(path: "/test")

		// Then
		#expect(sut.method == .get)
		#expect(sut.headers.isEmpty)
		#expect(sut.queryItems == nil)
		#expect(sut.body == nil)
	}

	@Test("Endpoint stores all parameters when provided")
	func acceptsAllParameters() {
		// Given
		let path = "/users"
		let method = HTTPMethod.post
		let headers = ["Content-Type": "application/json"]
		let queryItems = [URLQueryItem(name: "include", value: "profile")]
		let body = Data("{\"name\":\"test\"}".utf8)

		// When
		let sut = Endpoint(
			path: path,
			method: method,
			headers: headers,
			queryItems: queryItems,
			body: body,
		)

		// Then
		#expect(sut.path == path)
		#expect(sut.method == method)
		#expect(sut.headers == headers)
		#expect(sut.queryItems == queryItems)
		#expect(sut.body == body)
	}
}
