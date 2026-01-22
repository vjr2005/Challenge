import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import SwiftUI

struct ContentView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeFeature.makeHomeView(router: router)
                .navigationDestination(for: CharacterNavigation.self) { navigation in
                    CharacterFeature.view(for: navigation, router: router)
                }
        }
    }
}

#Preview {
    ContentView()
}
