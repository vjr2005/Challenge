import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import ChallengeNetworking
import ChallengeSystem
import SwiftUI

public struct AppContainer: Sendable {
	// MARK: - Shared Dependencies

	public let httpClient: any HTTPClientContract
	public let tracker: any TrackerContract

	// MARK: - Features

	private let homeFeature: HomeFeature
	private let characterFeature: CharacterFeature
	private let systemFeature: SystemFeature

	public var features: [any FeatureContract] {
		[homeFeature, characterFeature, systemFeature]
	}

	// MARK: - Init

	public init(
		httpClient: (any HTTPClientContract)? = nil,
		tracker: (any TrackerContract)? = nil
	) {
		self.httpClient = httpClient ?? HTTPClient(
			baseURL: AppEnvironment.current.rickAndMorty.baseURL
		)
		let providers = Self.makeTrackingProviders()
		providers.forEach { $0.configure() }
		self.tracker = tracker ?? Tracker(providers: providers)

		homeFeature = HomeFeature(tracker: self.tracker)
		characterFeature = CharacterFeature(httpClient: self.httpClient, tracker: self.tracker)
		systemFeature = SystemFeature(tracker: self.tracker)
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

// MARK: - Tracking Providers

private extension AppContainer {
	static func makeTrackingProviders() -> [any TrackingProviderContract] {
		[
            ConsoleTrackingProvider()
        ]
	}
}
