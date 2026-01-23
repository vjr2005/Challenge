import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import SwiftUI

struct ContentView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeFeature.makeHomeView(router: router)
                .characterNavigationDestination(router: router)
        }
        .onOpenURL { url in
            router.navigate(to: url)
        }
    }
}

#Preview {
    ContentView()
}
