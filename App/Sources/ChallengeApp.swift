import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import SwiftUI

@main
struct ChallengeApp: App {
    let features: [any Feature] = [
        CharacterFeature(),
        HomeFeature()
    ]

    init() {
        features.forEach { $0.registerDeepLinks() }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(features: features)
        }
    }
}
