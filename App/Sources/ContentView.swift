import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeFeature.makeHomeView(router: Router(path: $path))
                .navigationDestination(for: CharacterNavigation.self) { navigation in
                    CharacterFeature.view(for: navigation, router: Router(path: $path))
                }
        }
    }
}

#Preview {
    ContentView()
}
