import ChallengeCharacter
import ChallengeCore
import ChallengeEpisode
import ChallengeHome
import ChallengeNetworking
import ChallengeSystem
import SwiftUI

public struct AppContainer {
	// MARK: - Shared Dependencies

	private let launchEnvironment: LaunchEnvironment
	private let httpClient: any HTTPClientContract
	private let tracker: any TrackerContract
	let imageLoader: any ImageLoaderContract

	// MARK: - Features

	private let homeFeature: HomeFeature
	private let characterFeature: CharacterFeature
	private let episodeFeature: EpisodeFeature
	private let systemFeature: SystemFeature

	private var features: [any FeatureContract] {
		[
			homeFeature,
			characterFeature,
			episodeFeature,
			systemFeature
		]
	}

	// MARK: - Init

	public init(
		launchEnvironment: LaunchEnvironment = LaunchEnvironment(),
		httpClient: (any HTTPClientContract)? = nil,
		tracker: (any TrackerContract)? = nil,
		imageLoader: (any ImageLoaderContract)? = nil
	) {
		self.launchEnvironment = launchEnvironment
		self.imageLoader = imageLoader ?? CachedImageLoader()
		self.httpClient = httpClient ?? HTTPClient(
			baseURL: launchEnvironment.apiBaseURL ?? AppEnvironment.current.rickAndMorty.baseURL
		)
		self.tracker = tracker ?? Self.makeTracker()

		homeFeature = HomeFeature(tracker: self.tracker)
		characterFeature = CharacterFeature(httpClient: self.httpClient, tracker: self.tracker)
		episodeFeature = EpisodeFeature(httpClient: self.httpClient, tracker: self.tracker)
		systemFeature = SystemFeature(tracker: self.tracker)
	}

	// MARK: - Navigation Resolution

	func resolveView(
		for navigation: any NavigationContract,
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

	func handle(url: URL, navigator: any NavigatorContract) {
		navigator.navigate(to: navigation(from: url))
	}

	// MARK: - Factory Methods

	func makeRootView(navigator: any NavigatorContract) -> AnyView {
		if let url = launchEnvironment.deepLinkURL {
			resolveView(forDeepLink: url, navigator: navigator)
		} else {
			homeFeature.makeMainView(navigator: navigator)
		}
	}
}

// MARK: - Navigation Resolution

private extension AppContainer {
	func resolveView(forDeepLink url: URL, navigator: any NavigatorContract) -> AnyView {
		resolveView(for: navigation(from: url), navigator: navigator)
	}

	func navigation(from url: URL) -> any NavigationContract {
		for feature in features {
			guard let handler = feature.deepLinkHandler,
				  url.scheme == handler.scheme,
				  url.host == handler.host,
				  let navigation = handler.resolve(url) else {
				continue
			}
			return navigation
		}
		return UnknownNavigation.notFound
	}
}

// MARK: - Tracking

private extension AppContainer {
	static func makeTracker() -> Tracker {
		let providers: [any TrackingProviderContract] = [
			ConsoleTrackingProvider()
		]
		providers.forEach { $0.configure() }
		return Tracker(providers: providers)
	}
}
