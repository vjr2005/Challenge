import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import ChallengeNetworking
import ChallengeSystem
import SwiftUI

public struct AppContainer: Sendable {
	// MARK: - Shared Dependencies

	public let httpClient: any HTTPClientContract

	// MARK: - Features

	private let homeFeature: HomeFeature
	private let characterFeature: CharacterFeature
	private let systemFeature: SystemFeature

	public var features: [any FeatureContract] {
		[homeFeature, characterFeature, systemFeature]
	}

	// MARK: - Init

	public init(httpClient: (any HTTPClientContract)? = nil) {
		self.httpClient = httpClient ?? Self.makeHTTPClient()

		homeFeature = HomeFeature()
		characterFeature = CharacterFeature(httpClient: self.httpClient)
		systemFeature = SystemFeature()
	}

	private static func makeHTTPClient() -> HTTPClient {
		let transport: any HTTPTransportContract

		// Detect UI test mode via launch arguments
		if let configuration = StubConfiguration.fromLaunchArguments() {
			transport = StubTransport(configuration: configuration)
		} else {
			transport = URLSessionTransport()
		}

		return HTTPClient(
			baseURL: AppEnvironment.current.rickAndMorty.baseURL,
			transport: transport
		)
	}

	// MARK: - Navigation Resolution

	/// Resolves any navigation to a view by iterating through features.
	/// Falls back to NotFoundView if no feature can handle the navigation.
	public func resolve(
		_ navigation: any NavigationContract,
		navigator: any NavigatorContract
	) -> AnyView {
		for feature in features {
			if let view = feature.resolve(navigation, navigator: navigator) {
				return view
			}
		}
		// Fallback to SystemFeature's main view (NotFoundView)
		return systemFeature.makeMainView(navigator: navigator)
	}

	// MARK: - Deep Link Handling

	public func handle(url: URL, navigator: any NavigatorContract) {
		for feature in features {
			if let navigation = feature.deepLinkHandler?.resolve(url) {
				navigator.navigate(to: navigation)
				return
			}
		}
		// If no feature can handle the URL, navigate to NotFound
		navigator.navigate(to: UnknownNavigation.notFound)
	}

	// MARK: - Factory Methods

	public func makeRootView(navigator: any NavigatorContract) -> AnyView {
		homeFeature.makeMainView(navigator: navigator)
	}
}
