import SwiftUI

@main
struct ChallengeApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(features: container.features)
        }
    }
}
