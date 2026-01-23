import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import SwiftUI

@main
struct ChallengeApp: App {
    static let features: [any Feature] = [
        CharacterFeature(),
        HomeFeature()
    ]

    init() {
        Self.features.forEach { $0.registerDeepLinks() }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(features: Self.features)
        }
    }
}
