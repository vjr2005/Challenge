import ChallengeCharacter
import SwiftUI

@main
struct ChallengeApp: App {
    init() {
        registerDeepLinks()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func registerDeepLinks() {
        CharacterFeature.registerDeepLinks()
    }
}
