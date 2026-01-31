import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import ChallengeNetworking
import ChallengeSystem
import SwiftUI

struct AppContainer: Sendable {
    // MARK: - Shared Dependencies

    let httpClient: any HTTPClientContract

    // MARK: - Features

    private let homeFeature: HomeFeature
    private let characterFeature: CharacterFeature
    private let systemFeature: SystemFeature

    var features: [any Feature] {
        [homeFeature, characterFeature, systemFeature]
    }

    // MARK: - Init

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: AppEnvironment.current.rickAndMorty.baseURL
        )

        self.homeFeature = HomeFeature()
        self.characterFeature = CharacterFeature(httpClient: self.httpClient)
        self.systemFeature = SystemFeature()
    }

    // MARK: - Navigation Resolution

    /// Resolves any navigation to a view by iterating through features.
    /// Falls back to NotFoundView if no feature can handle the navigation.
    func resolve(
        _ navigation: any IncomingNavigation,
        navigator: any NavigatorContract
    ) -> AnyView {
        for feature in features {
            if let view = feature.tryResolve(navigation, navigator: navigator) {
                return view
            }
        }
        // Fallback - should not happen if all navigations are properly handled
        return systemFeature.resolve(.notFound, navigator: navigator)
    }

    // MARK: - Deep Link Handling

    func handle(url: URL, navigator: any NavigatorContract) {
        for feature in features {
            if let navigation = feature.deepLinkHandler?.resolve(url) {
                navigator.navigate(to: navigation)
                return
            }
        }
    }

    // MARK: - Factory Methods

    func makeRootView(navigator: any NavigatorContract) -> some View {
        homeFeature.makeHomeView(navigator: navigator)
    }
}
