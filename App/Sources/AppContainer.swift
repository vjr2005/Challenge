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

    let features: [any Feature]

    // MARK: - Init

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: AppEnvironment.current.rickAndMorty.baseURL
        )

        self.features = [
            CharacterFeature(httpClient: self.httpClient),
            HomeFeature(),
            SystemFeature()
        ]
    }

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
        HomeFeature().makeHomeView(navigator: navigator)
    }
}
