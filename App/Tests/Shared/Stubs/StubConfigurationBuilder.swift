import ChallengeCore
import Foundation

/// Builder for fluent stub configuration in UI tests.
/// Loads fixtures from the test bundle and embeds them in the configuration.
/// nonisolated because it is used from XCTestCase setUpWithError which runs outside MainActor.
nonisolated final class StubConfigurationBuilder {
	private var routes: [StubConfiguration.Route] = []
	private let bundle: Bundle

	init(bundle: Bundle) {
		self.bundle = bundle
	}

	/// Creates a builder using the module bundle.
	/// Call this from a MainActor context.
	@MainActor
	static func create() -> StubConfigurationBuilder {
		StubConfigurationBuilder(bundle: Bundle.module)
	}

	/// Adds a stub for a route with a JSON fixture from the test bundle.
	/// The fixture is loaded and encoded in Base64.
	@discardableResult
	func stub(
		path pathPattern: String,
		status: Int = 200,
		fixture: String
	) -> Self {
		let data = loadFixture(named: fixture)
		routes.append(StubConfiguration.Route(
			pathPattern: pathPattern,
			statusCode: status,
			bodyBase64: data.base64EncodedString(),
			contentType: "application/json"
		))
		return self
	}

	/// Adds a stub for a route with inline data (e.g., images).
	@discardableResult
	func stub(
		path pathPattern: String,
		status: Int = 200,
		data: Data,
		contentType: String
	) -> Self {
		routes.append(StubConfiguration.Route(
			pathPattern: pathPattern,
			statusCode: status,
			bodyBase64: data.base64EncodedString(),
			contentType: contentType
		))
		return self
	}

	/// Adds an error stub.
	@discardableResult
	func stubError(path pathPattern: String, status: Int = 500) -> Self {
		let errorBody = Data("{\"error\":\"Stubbed error\"}".utf8)
		routes.append(StubConfiguration.Route(
			pathPattern: pathPattern,
			statusCode: status,
			bodyBase64: errorBody.base64EncodedString(),
			contentType: "application/json"
		))
		return self
	}

	func build() -> StubConfiguration {
		StubConfiguration(routes: routes)
	}

	private func loadFixture(named name: String) -> Data {
		guard let url = bundle.url(forResource: name, withExtension: "json"),
			  let data = try? Data(contentsOf: url) else {
			fatalError("Fixture '\(name).json' not found in bundle")
		}
		return data
	}
}
