import XCTest

/// Base protocol for all screen robots.
protocol RobotContract {
	var app: XCUIApplication { get }
}

/// Base class for UI tests with stub configuration support.
nonisolated class UITestCase: XCTestCase {
	/// The base URL used for stub configuration.
	static let baseURL = "https://rickandmortyapi.com/api"

	private(set) var app: XCUIApplication!
	private var stubDirectory: URL?
	private var stubConfiguration: StubConfiguration?

	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		executionTimeAllowance = 60
	}

	override func tearDownWithError() throws {
		if let directory = stubDirectory {
			StubConfigurationWriter.cleanup(directory: directory)
		}
		stubDirectory = nil
		stubConfiguration = nil
		app = nil
		try super.tearDownWithError()
	}

	/// Configures stub endpoints for the test.
	/// Call this before `launch()`.
	/// - Parameter endpoints: The stub endpoints to configure.
	func configureStubs(_ endpoints: [EndpointStub]) {
		stubConfiguration = StubConfiguration(
			baseURL: Self.baseURL,
			endpoints: endpoints,
			defaultResponse: .notFound(path: "/*")
		)
	}

	/// Launches the app with the configured stub endpoints.
	/// Call `configureStubs(_:)` before calling this method.
	/// - Returns: The launched XCUIApplication instance.
	@MainActor
	@discardableResult
	func launch() -> XCUIApplication {
		let app = XCUIApplication()

		if let configuration = stubConfiguration {
			stubDirectory = StubConfigurationWriter.createStubDirectory()
			guard let directory = stubDirectory else {
				fatalError("Failed to create stub directory")
			}

			let configPath = StubConfigurationWriter.write(configuration, to: directory)
			app.launchEnvironment = [StubConfigurationWriter.configPathKey: configPath]
		}

		app.launch()
		self.app = app
		return app
	}

	@MainActor
	func home(actions: (HomeRobot) -> Void) {
		actions(HomeRobot(app: app))
	}

	@MainActor
	func characterList(actions: (CharacterListRobot) -> Void) {
		actions(CharacterListRobot(app: app))
	}

	@MainActor
	func characterDetail(actions: (CharacterDetailRobot) -> Void) {
		actions(CharacterDetailRobot(app: app))
	}

	@MainActor
	func notFound(actions: (NotFoundRobot) -> Void) {
		actions(NotFoundRobot(app: app))
	}
}
