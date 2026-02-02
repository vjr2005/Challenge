import Foundation
import Testing

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct StubConfigurationTests {
	// MARK: - Tests

	@Test("Creates route with default values")
	func createsRouteWithDefaultValues() {
		// When
		let route = StubConfiguration.Route(pathPattern: "/api/test")

		// Then
		#expect(route.pathPattern == "/api/test")
		#expect(route.statusCode == 200)
		#expect(route.bodyBase64.isEmpty)
		#expect(route.contentType == "application/json")
	}

	@Test("Creates route with custom values")
	func createsRouteWithCustomValues() {
		// Given
		let bodyData = Data("{\"error\":\"Not found\"}".utf8)

		// When
		let route = StubConfiguration.Route(
			pathPattern: "/api/missing",
			statusCode: 404,
			bodyBase64: bodyData.base64EncodedString(),
			contentType: "application/json"
		)

		// Then
		#expect(route.pathPattern == "/api/missing")
		#expect(route.statusCode == 404)
		#expect(route.bodyBase64 == bodyData.base64EncodedString())
		#expect(route.contentType == "application/json")
	}

	@Test("Serializes and deserializes to launch argument format")
	func serializesAndDeserializesToLaunchArgument() throws {
		// Given
		let bodyData = Data("{\"id\":1}".utf8)
		let route = StubConfiguration.Route(
			pathPattern: "/api/test",
			statusCode: 200,
			bodyBase64: bodyData.base64EncodedString()
		)
		let config = StubConfiguration(routes: [route])

		// When
		let args = config.toLaunchArgument()

		// Then
		#expect(args.count == 2)
		#expect(args[0] == "--stub-config")

		// Verify we can decode back
		let jsonData = try #require(Data(base64Encoded: args[1]))
		let decoded = try JSONDecoder().decode(StubConfiguration.self, from: jsonData)
		#expect(decoded.routes.count == 1)
		#expect(decoded.routes[0].pathPattern == "/api/test")
		#expect(decoded.routes[0].statusCode == 200)
		#expect(decoded.routes[0].bodyBase64 == bodyData.base64EncodedString())
	}

	@Test("Creates configuration with multiple routes")
	func createsConfigurationWithMultipleRoutes() {
		// When
		let config = StubConfiguration(routes: [
			StubConfiguration.Route(pathPattern: "/api/users"),
			StubConfiguration.Route(pathPattern: "/api/posts", statusCode: 201),
			StubConfiguration.Route(pathPattern: "/api/error", statusCode: 500)
		])

		// Then
		#expect(config.routes.count == 3)
		#expect(config.routes[0].pathPattern == "/api/users")
		#expect(config.routes[1].statusCode == 201)
		#expect(config.routes[2].statusCode == 500)
	}
}
